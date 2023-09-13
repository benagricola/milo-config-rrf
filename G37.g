; G37.g
; Probe the current tool length and save its' offset.
; We calculate the offset based on the height of the
; toolsetter, and its' offset to the material surface
; we're working with.
;
; Operators _must_ call G6013 before this macro,
; as the reference surface must be probed with a touch
; probe, which will interfere with the tool changing
; process.
; You should call G6013 in the preamble of your gcode
; file, if you are expecting to have to change tools.
;
;
; USAGE: "G37"
;
; NOTE: This is designed to work with a NEGATIVE Z - that is, MAX is 0 and MIN is -<something>

M5       ; stop spindle just in case

G21      ; Switch to mm

G27      ; park spindle

; Variables used to store tool position references.
var expectedToolZ   = global.referenceSurfaceZ + global.toolSetterHeight ; Expected toolsetter activation height
                                                                         ; if tool has exactly the same stickout
                                                                         ; as the touch probe used to probe the
                                                                         ; reference surface.
 
var actualToolZ     = 0 ; Actual Z co-ordinate probed with tool
var toolOffset      = 0 ; The calculated offset of the tool

; Select next tool if current tool unset
var toolIndex = state.currentTool == -1 ? state.nextTool : state.currentTool

; Check all required parameters
if { exists(param.I) && param.I > -1 }
    set var.toolIndex = param.I

; Reset tool Z offset
if { var.toolIndex == -1 }
    abort {"No tool selected, run T<N> to select a tool!"}


if { var.expectedToolZ == 0 }
    abort {"Expected tool height is not properly probed!"}

G10 P{global.spindleID} Z0

; Deactivate spindle
M98 P"tool-deactivate.g"

M118 P0 L2 S{"Probing tool #" ^ var.toolIndex ^ " length at X=" ^ global.toolSetterX ^ ", Y=" ^ global.toolSetterY }

; Probe tool length multiple times and average
; Allow operator to jog tool over bolt after rough probing move to confirm
; lowest tool point.
G6012 X{global.toolSetterX} Y{global.toolSetterY} S{global.zMax} B{global.toolSetterDistanceZ} I{global.toolSetterJogDistanceZ} J1 K{global.toolSetterID} C{global.toolSetterNumProbes} V{global.toolSetterProbeSpeed}

; Our tool offset is the difference between our expected tool Z and our actual
; tool Z. Expected tool Z is calculated during G6013 by probing the reference
; surface and then adding the offset of the toolsetter to it.
set var.actualToolZ = global.probeCoordinateZ
set var.toolOffset = var.actualToolZ - var.expectedToolZ
M118 P0 L2 S{"Tool #" ^ var.toolIndex ^ " Expected Tool Z =" ^ var.expectedToolZ ^ ", Actual Tool Z=" ^ var.actualToolZ ^ " Tool Offset = " ^ var.toolOffset }

; Re-activate spindle before setting offset, otherwise
; the tool offset is lost.
M98 P"tool-activate.g"

G10 P{global.spindleID} X0 Y0 Z{-var.toolOffset}

; Park.
G27
