# -*- coding: utf-8 -*-
# Millenium Machines Milo v1.5 Postprocessor for FreeCAD.
# 
# Copyright (C)2022-2023 Millenium Machines
# 
# This postprocessor assumes that most complex functionality like
# tool changes and work coordinate setting is handled in the machine firmware.
# 
# Calls in to these systems should be a single macro call, preferably using a custom
# gcode rather than macro filename, and how the gcode handles the task in question
# (e.g. tool length calculation being automatic or manual) is a concern for the
# firmware, _not_ this post-processor.
# 
# As such, it is a very simple post-processor and only supports 3 axis and one
# spindle. It will NOT output any gcode that we are not 100% certain
# will be safe, based on the following assumptions:
# 
# - Your G27 (Park) macro raises Z away from the work piece _before_ running M5.
# - It is the responsibility of your macros to run M5 where needed!
# - It is the responsibility of your macros and firmware to run any safety checks.

import sys
import pprint
import argparse
import shlex
from enum import StrEnum, Flag, auto
from contextlib import contextmanager
import FreeCAD
from FreeCAD import Units
import Path
import Path.Base.Util as PathUtil
import Path.Post.Utils as PostUtils

from datetime import datetime, timezone

# User-configurable arguments.
parser = argparse.ArgumentParser(prog="millennium_milo_v1.5", 
    description="Millennium Machines Milo v1.5 Post Processor for FreeCAD")

parser.add_argument('--show-editor', action=argparse.BooleanOptionalAction, default=True,
    help="Show Gcode in FreeCAD Editor before saving to file.")

parser.add_argument('--output-machine', action=argparse.BooleanOptionalAction, default=True,
    help="Output machine settings header.")

parser.add_argument('--output-tools', action=argparse.BooleanOptionalAction, default=True, 
    help="Output tool details. Disabling this will make tool changes much harder!")

parser.add_argument('--output-version', action=argparse.BooleanOptionalAction, default=True,
    help="Output version details header.")

parser.add_argument('--home-before-start', action=argparse.BooleanOptionalAction, default=True,
    help="When enabled, machine will home in X, Y and Z directions prior to executing any operations.")

parser.add_argument('--probe-workpiece-before-start', action=argparse.BooleanOptionalAction, default=True,
    help="When enabled, machine will execute G6001 to probe a top corner prior to executing any operations.")

parser.add_argument('--probe-workpiece-on-wcs-change', action=argparse.BooleanOptionalAction, default=True,
    help="When enabled, machine will execute G6001 to probe a top corner and set WCS Zero prior to changing into that WCS.")

parser.add_argument(
    "--wait-for-spindle",
    type=int,
    default=20,
    help="""
    When set, machine will wait (dwell) for this number of seconds after starting or stopping the spindle 
    to allow it to accelerate or decelerate to the target speed."""
)

parser.add_argument(
    "--vssc-period",
    type=int,
    default=2000,
    help="Period over which RPM is varied up and down when VSSC is enabled, in milliseconds."
)
parser.add_argument(
    "--vssc-variance",
    type=int,
    default=100,
    help="Variance above and below target RPM to vary Spindle speed when VSSC is enabled, in RPM."
)
parser.add_argument('--vssc', action=argparse.BooleanOptionalAction, default=True, 
    help="""
    When enabled, spindle speed is varied between an upper and lower limit surrounding the requested RPM 
    which helps to avoid harmonic resonance between tool and work piece.
    """)

parser.add_argument('--tool-length-warning', action=argparse.BooleanOptionalAction, default=True,
    help="""
    When enabled, FreeCAD console messages will be emitted when tools reach a negative Z value lower 
    than their cutting length. This does not abort post-processing but may indicate situations 
    where a tool or workpiece could be damaged. This warning assumes your WCS zero point is at the
    TOP of the part."""
)

class GCODES:
    # Define G code constants for non-standard or regularly used gcodes.
    DWELL        = 4
    PARK         = 27
    HOME         = 28
    PROBE_TOOL   = 37
    PROBE_CORNER = 6001
    PROBE_REF    = 6013

class MCODES:
    # Define M code constants for non-standard or regularly used mcodes.
    ADD_TOOL     = 4000
    VSSC_ENABLE  = 7000
    VSSC_DISABLE = 7001
    PROBE_REMOVE = 7003

# Define format strings for variable and command types
class FORMATS:
    CMD   = '{:0.3f}'
    AXES  = '{:0.3f}'
    TOOLS = '{:0.0f}'
    RPM   = '{:0.0f}'
    STR   = '"{!s}"'
    WCS   = '{:0.0f}'
    FEED  = '{:0.3f}'

# FreeCAD Unit Value Types
# Values will be converted _to_ these
# formats for output.
class UNITS:
    FEED   = 'mm/min'
    LENGTH = 'mm'

# Well-known arguments
# Used to reference arg values for
# additional processing
class ARGS:
    Z    = 'Z'
    FEED = 'F'
    TOOL = 'T'

# Define Output control flags
class Control(Flag):
    NONE    = 0
    FORCE   = auto()
    STRICT  = auto()
    NONZERO = auto()

# Define output class. This is used to output both
# commands and their nested variables. Output() instances
# can be nested into other output instances inside the 'vars'
# argument.
class Output:
    def __init__(self, fmt='{!s}', prefix=None, ctrl=Control.NONE, vars = None):
        # Take input settings and assign to instance vars
        # if set.
        if fmt is not None:
            self.fmt = fmt
        if prefix is not None:
            self.prefixStr = prefix

        self.varFormats = {}

        if vars is not None:
            for v in vars:
                prefix = v.prefix()
                self.varFormats[prefix] = v

        self.ctrl = ctrl
        self.lastVars = ()
        self.lastCode = None

    # Force output of matching prefixes on
    # next command.
    def reset(self, prefixes):
        for prefix in prefixes:
            if prefix in self.varFormats:
                self.varFormats[prefix].reset([prefix,])

            if self.prefix() == prefix:
                self.lastCode = None
                self.lastVars = None
            
    # Return the current prefix string
    def prefix(self):
        return self.prefixStr

    # Format the given arguments
    def format(self, *args, **kwargs):
        ctrl = kwargs.pop('ctrl', self.ctrl)

        out = self.fmt.format(*args, **kwargs)

        # This is crap. There's no way to remove
        # trailing zeroes from a formatted float
        # so we just strip them manually if a decimal
        # separator exists in the string.
        if '.' in out:
            out = out.rstrip('0').rstrip('.')
        
        # This is also crap, but with inexact
        # floats we might end up with negative
        # zero after formatting, so we need to
        # fix before output. 
        if out == '-0':
            out = '0'

        if out == '0' and Control.NONZERO in ctrl:
            return None
        
        return self.prefix() + out

    # When called, process the code and arguments
    # and output if necessary
    def __call__(self, code, **kwargs):
        ctrl = kwargs.pop('ctrl', self.ctrl)

        frozenvars = (code, frozenset(kwargs.items()))

        # If code and args are the same as last then suppress if
        # force is false.
        if frozenvars == self.lastVars and not (Control.FORCE in ctrl):
            return (None, None)
        
        self.lastVars = frozenvars


        # If code has changed or force is enabled, output
        # the code.
        outCode = None
        if code != self.lastCode or Control.FORCE in ctrl:
            outCode = self.format(code, ctrl=ctrl)
            if outCode is None:
                return (None, None)
            self.lastCode = code

        # Parse args. We do this regardless of if the code
        # is output because arguments sent on new lines are
        # treated as successive calls to the last G or M
        # code.
        outCmd     = [outCode] if outCode else []
        outChanged = {}

        for k, v in kwargs.items():
            if k in self.varFormats:
                argOut, _ = self.varFormats[k](v)
                if argOut is not None: 
                    outCmd.append(''.join(argOut[0]))
                    # Store index in cmd list of changed key
                    # Necessary because we don't always output
                    # the command itself.
                    outChanged[k] = len(outCmd)-1
            # If strict is not set, output arg key and value
            # in their string formats.
            elif not Control.STRICT in ctrl:
                outCmd.append('{!s}{!s}'.format(k, v))
                outChanged[k] = len(outCmd)-1
        
        # If the command had arguments but none have changed
        # then do not output the command at all.
        if kwargs and not outChanged:
            return (None, None)

        return (outCmd, outChanged)

# Define post-processor sections
class Section(StrEnum):
    PRE  = auto()
    RUN  = auto()
    POST = auto()

# Implements a generalised post-processor 
class PostProcessor:
    name      = "FreeCAD Post-Processor"
    vendor    = "Unknown"

    def __init__(self, name=None, vendor=None, args={}):
        if name is not None:
            self.name = name
        if vendor is not None:
            self.vendor = vendor
        
        # Set args
        self.args  = args

        # Set default instance vars
        self.tools = {}

        setattr(self, Section.RUN, [])
        setattr(self, Section.PRE, [])
        setattr(self, Section.POST, [])

        # Set default section
        self.oldSection = Section.RUN
        self.curSection = Section.RUN

        # Switch to PRE section
        with self.Section(Section.PRE):
            self.comment('Exported by FreeCAD')
            self.comment('Post Processor: {}'.format(self.name, self.vendor))
            self.comment('Output Time: {}'.format(datetime.now(timezone.utc)))
            self.brk()

    @contextmanager
    def Section(self, section):
        self.oldSection = self.curSection
        self.curSection = section
        try:
            yield
        finally:
            self.curSection = self.oldSection
            self.oldSection = Section.RUN

    def parse(self, objects, skip_inactive=True):
        with self.Section(Section.RUN):
            for o in objects:
                # Recurse over compound objects
                if hasattr(o, 'Group'):
                    for p in o.Group:
                        self.parse(p, skip_inactive=False)

                # Skip non-path objects
                if not hasattr(o, 'Path'):
                    continue
            
                # Skip inactive operations
                if skip_inactive and PathUtil.opProperty(o, 'Active') is False:
                    continue
                self._parseobj(o)
            print("Parsed Objects: ", len(objects))

    # Default object parsing just outputs a 'begin operation'
    # comment and triggers parsing of each command
    def _parseobj(self, obj):
        self.comment('Begin Operation: {}'.format(obj.Label))
        
        # Save details about tools used
        tc = PathUtil.toolControllerForOp(obj)
        if tc:
            self.add_tool(tc.ToolNumber, tc.Tool.Label)

        for c in obj.Path.Commands:
            self._parsecmd(c)

    # Default parameter parsing just outputs a key value pair
    # and will only accept numeric arguments.
    def _parseparam(self, key, value):
        # TODO: Check if number.
        return '{}{:0.3f}'.format(key, value)

    # Default operation parsing just outputs operation name
    # and arguments without any processing.
    def _parsecmd(self, cmd):
        params = [cmd.Name, ]
        for pkey, pval in cmd.Parameters.items():
            param = self._parseparam(pkey, pval)
            if param:
                params.append(param)
        self.cmd(' '.join(params))

    # Add tool index, description pair to tool info
    def add_tool(self, index, description):
        if index in self.tools and description != self.tools[index]:
            raise ValueError("Duplicate tool index {} with different descriptions!".format(index))
        
        self.tools[index] = description

    # Return tool info
    def toolinfo(self):
        return self.tools

    # Output a comment to the active section
    def comment(self, msg):
        a = getattr(self, self.curSection)
        a.append('({})'.format(msg))

    # Output a command to the active section
    def cmd(self, cmd):
        if cmd is not None:
            a = getattr(self, self.curSection)
            a.append(cmd)

    # Output a break to the active section
    def brk(self):
        a = getattr(self, self.curSection)
        a.append('')

    # Concat and output the sections
    def output(self):
        out = getattr(self, Section.PRE)
        out.extend(getattr(self, Section.RUN))
        out.extend(getattr(self, Section.POST))
        return '\n'.join(out)

class FreeCADPostProcessor(PostProcessor):
    _RAPID_MOVES     = [0]
    _LINEAR_MOVES    = [0, 1]
    _ARC_MOVES       = [2, 3]
    _SPINDLE_ACTIONS = [3, 4]
    _TOOL_CHANGES    = [6]
    _WCS_CHANGES     = [54, 55, 56, 57, 58, 59]

    # Define command output formatters
    _G   = Output(fmt=FORMATS.CMD, prefix='G', vars = [
            Output(prefix='X', fmt=FORMATS.AXES),
            Output(prefix='Y', fmt=FORMATS.AXES),
            Output(prefix='Z', fmt=FORMATS.AXES),
            Output(prefix='I', fmt=FORMATS.AXES, ctrl=Control.NONZERO),
            Output(prefix='J', fmt=FORMATS.AXES, ctrl=Control.NONZERO),
            Output(prefix='K', fmt=FORMATS.AXES, ctrl=Control.NONZERO),
            Output(prefix='F', fmt=FORMATS.FEED, ctrl=Control.NONZERO),
            Output(prefix='R', fmt=FORMATS.STR),
            Output(prefix='W', fmt=FORMATS.WCS)
        ], ctrl=Control.FORCE)

    _M   = Output(fmt=FORMATS.CMD, prefix='M', vars = [
            Output(prefix='I', ctrl=Control.FORCE),
            Output(prefix='D', fmt=FORMATS.STR, ctrl=Control.FORCE),
            Output(prefix='T', fmt=FORMATS.TOOLS, ctrl=Control.FORCE),
            Output(prefix='S', fmt=FORMATS.RPM, ctrl=Control.FORCE),
        ], ctrl=Control.FORCE)
    
    _T   = Output(fmt=FORMATS.CMD, prefix='T')

    def __init__(self, args={}):
        super().__init__(name="Milo v1.5", vendor="Millennium Machines", args=args)
        self._MOVES = self._LINEAR_MOVES + self._ARC_MOVES
        self.active_wcs = False
        self.cur_tool_length = None
        self.min_op_z = None # Use None rather than 0 as min Z might be positive
        self.min_z = None

        with self.Section(Section.PRE):
            # Warn operator 
            self.comment("WARNING: This gcode was generated to target a singular firmware configuration for RRF.")
            self.comment("This firmware implements various safety checks and spindle controls that are assumed by this gcode to exist.")
            self.comment("DO NOT RUN THIS GCODE ON A MACHINE OR FIRMWARE THAT DOES NOT CONTAIN THESE CHECKS!")
            self.comment("You are solely responsible for any injuries or damage caused by not heeding this warning!")
            self.brk()

    def _forceFeed(self):
        self._G.reset([ARGS.FEED,])

    def zMin(self, reset=False):
        z = self.min_z
        if reset:
            self.min_z = None
        return z

    def T(self, code):
        cmd, _ = self._T(code)
        if not cmd:
            return None
        return self.cmd(' '.join(cmd))

    def G(self, code, **params):
        # Parse and format the command into a list
        cmd, changed = self._G(code, **params)
        if not cmd:
            return None
        
        # If WCS is changing
        if code in self._WCS_CHANGES:
            doProbe = (not self.active_wcs and self.args.probe_workpiece_before_start) or self.args.probe_workpiece_on_wcs_change
            
            wcsOffset = int(code - (self._WCS_CHANGES[0]-1))

            # If probe is necessary
            if doProbe:
                # If we're changing from an active WCS
                # then park first, as this likely involves a
                # fixture change or part movement.
                if self.active_wcs:
                    self.comment("Park ready for WCS change")
                    self.G(GCODES.PARK)
                    self.brk()
                
                # Run corner probing mechanism 
                self.comment("Probe origin corner and save in WCS {}".format(wcsOffset))
                self.G(GCODES.PROBE_CORNER, W=wcsOffset)
                self.brk()
                self.comment("Prompt operator to remove touch probe before continuing")
                self.M(MCODES.PROBE_REMOVE)
                self.brk()
                self.comment("Switch to WCS {}".format(wcsOffset))

        # If feed arg will be output
        if ARGS.FEED in changed:
            # But the code is a move with only a feed arg
            # Then do not output the command at all and
            # make sure it is outputted with the next command
            if code in self._MOVES and len(changed) == 1:
                self._forceFeed()
                return None
            # And command is a rapid move
            if code in self._RAPID_MOVES:
                # Then ignore the feed arg
                # as rapid moves follow machine limits
                del cmd[changed[ARGS.FEED]]
                # Make sure feed is output by the next 
                # non-rapid move.
                self._forceFeed()

        if code in self._MOVES and not changed:
            return
        return self.cmd(' '.join(cmd))
        

    def M(self, code, **params):
        # If code is a tool change, send the tool parameter as a command first
        if ARGS.TOOL in params and code in self._TOOL_CHANGES:
            self.T(params[ARGS.TOOL])
            del params[ARGS.TOOL]
        
        cmd, args = self._M(code, **params)
        if not cmd:
            return None

        self.cmd(' '.join(cmd))

        # If command is setting a spindle action, then wait for
        # the spindle to reach the desired speed.
        if code in self._SPINDLE_ACTIONS and self.args.wait_for_spindle > 0:
            self.G(GCODES.DWELL, S=self.args.wait_for_spindle)
        
    def _parseobj(self, obj):
        # Store current tool cutting height
        tc = PathUtil.toolControllerForOp(obj)
        if tc:
            if tc.Tool.CuttingEdgeHeight > 0:
                self.cur_tool_length = Units.Quantity(tc.Tool.CuttingEdgeHeight, FreeCAD.Units.Length).getValueAs(UNITS.LENGTH)
        
        # Set min Z to 0 (assume Z=0 is the top of the work piece)
        if self.args.tool_length_warning:
            self.min_op_z = 0

        # Call parent object parsing method
        super()._parseobj(obj)

        # Note: This warning is pretty naiive because a tool can descend to a Z depth
        # lower than its' cutting height without being engaged in any material.
        # It is up to the operator to act on this warning and check whether this is
        # a mistake or intended. 
        if self.args.tool_length_warning:
            if self.min_op_z is not None and self.cur_tool_length is not None:
                if self.min_op_z + self.cur_tool_length <= 0:  
                    print(("WARNING: Tool {} cutting edge height {} is less than min Z={:0.3f}" + 
                        " - please double check your {} tool path and confirm it will not engage" + 
                        " your work piece deeper than its' cutting edge height!").format(tc.Tool.Label, self.cur_tool_length, self.min_op_z, obj.Label))
    
    def _parsecmd(self, cmd):
        ctype = cmd.Name[0].upper()

        # FreeCAD intersperses internal comments with
        # commands so we have to handle these as well.
        # For the moment, just skip.
        if ctype == '(':
            return
        
        # We convert to float since some commands can have
        # extended (decimal) values
        code = float(cmd.Name[1:])

        params = {}

        for pkey, pvalue in cmd.Parameters.items():
            v = self._parseparam(code, pkey, pvalue)
            if v:
                params[pkey] = v

        match ctype:
            case 'G':
                self.G(code, **params)
            case 'M':
                self.M(code, **params)
            case _:
                raise ValueError("Unknown command type {}".format(cmd.Name))

    # Convert necessary parameters based on FreeCAD units.
    def _parseparam(self, code, key, value):
        match key:
            # Convert FreeCAD feed-rate to machine feed rate
            case ARGS.FEED:
                rate = Units.Quantity(value, FreeCAD.Units.Velocity)
                return float(rate.getValueAs(UNITS.FEED))
            # Track lowest total Z-height and max and min z-height per operation
            case ARGS.Z:
                val = Units.Quantity(value, FreeCAD.Units.Length)
                f = float(val.getValueAs(UNITS.LENGTH))
                if self.min_z is None or f < self.min_z:
                    self.min_z = f

                if self.args.tool_length_warning:
                    if self.min_op_z is None or f < self.min_op_z:
                        self.min_op_z = f
                return f
            # Convert all other floats to machine lengths
            case float():
                val = Units.Quantity(value, FreeCAD.Units.Length)
                return float(val.getValueAs(UNITS.LENGTH))
            # Return all other values as-is (likely strings)
            case _:
                return value
                
    def rapid(self, x, y, z):
        return self.G(0, X=x, Y=y, Z=z, ctrl=Control.FORCE)

    def linear(self, x, y, z, f):
        return self.G(1, X=x, Y=y, Z=z, F=f, ctrl=Control.FORCE)


# Parse and export the CAM objects.
def export(objectslist, filename, argstring):
    try:
        args = parser.parse_args(shlex.split(argstring))
    except Exception as e:
        import pprint
        pprint.pprint(e)
        sys.exit(1)

    # Instantiate FreeCAD post-processor
    pp = FreeCADPostProcessor(args=args)

    with pp.Section(Section.PRE):
        pp.comment("Begin preamble")

        # Parse always outputs to RUN section
        pp.parse(objectslist)
        pp.comment("Minimum Height Z={:.3f}".format(pp.zMin()))
        pp.brk()

        # Parsing must be completed to enumerate all tools.
        tools = pp.toolinfo()

        if args.output_tools and tools:
            pp.comment("Pass tool details to firmware")
            # Output tool info
            for index, description in tools.items(): 
                pp.M(MCODES.ADD_TOOL, I=index, D=description, ctrl=Control.FORCE)
            pp.brk()
    
        if args.home_before_start:
            pp.comment("Home before start")
            pp.G(GCODES.HOME)
            pp.brk()

        pp.comment("Movement configuration")
        pp.G(90) # Absolute moves
        pp.G(21) # All units are millimeters
        pp.G(94) # Feeds are per-minute
        pp.brk()

        if tools:
            pp.comment("Probe reference surface prior to tool changes")
            pp.G(GCODES.PROBE_REF)
            pp.brk()
        
        if args.vssc:
            pp.comment("Enable Variable Spindle Speed Control")
            pp.M(MCODES.VSSC_ENABLE, P=args.vssc_period, V=args.vssc_variance)
            pp.brk()

    # Switch to post to output ending commands
    with pp.Section(Section.POST):
        pp.comment("Begin postamble")
        pp.comment("Park at user-defined location")
        pp.G(GCODES.PARK)
        pp.brk()

        if args.vssc:
            pp.comment("Disable Variable Spindle Speed Control")
            pp.M(MCODES.VSSC_DISABLE)
            pp.brk()
        
        pp.comment("Double-check spindle is stopped!")
        pp.M(5)
        pp.brk()
        pp.comment("End Program")
        pp.M(5)


    out = pp.output()
    
    # If GUI requested, open editor window
    if FreeCAD.GuiUp and args.show_editor:
        out = PostUtils.editor(out)

    with open(filename, "w") as f:
        f.write(out)