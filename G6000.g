; G6000.g
; Probe cuboid workpiece outer dimensions from X and Y boundaries
; and allow selection of each top corner as WCS Zero.
;
; USAGE: "G6000"
; OPTIONAL PARAMS:
;   X<approx-length-of-workpiece-in-x> Y<approx-length-of-workpiece-in-y> I<probe-height-below-surface>

; NOTE: MUST be used with a negative Z (so 0 to -<n> rather than 0 to <n>)

M5       ; stop spindle just in case

G21      ; Switch to mm

; Variables used to store material position references.
var materialZ          = 0           ; Probed surface of material, Z
var safeZ              = 0           ; Known safe height for moves, Z
var materialX1         = global.xMin ; Material left edge
var materialX2         = global.xMax ; Material right edge
var materialY1         = global.yMax ; Material front edge
var materialY2         = global.yMin ; Material back edge
var materialCtrX       = 0           ; Calculated center of material, X
var materialCtrY       = 0           ; Calculated center of material, Y
var materialOpCtrX     = 0           ; Operator approximate center of material, X
var materialOpCtrY     = 0           ; Operator approximate center of material, Y
var materialOpLenX     = 0           ; Operator approximate material length, X
var materialOpLenY     = 0           ; Operator approximate material length, Y
var probeDepthRelative = 0           ; Depth below material surface to probe edges

; Check if touchprobe feature is available
if {!exists(global.featureTouchProbe) || !global.featureTouchProbe }
    ; TODO: Walk user through manual probing process
    abort "Unable to probe material without touch probe!"


; Park, request center of X and Y as this is
; likely close to where the user needs to jog to.
G27 C1

; Start probing sequence
M291 P"Install touch probe in spindle and confirm it is plugged in!" R"Installation check" S3

; Prompt user to place the touch probe over the work piece
M291 P"Jog the Touch Probe above the approximate centre of the workpiece" R"Find height of workpiece" S3 X1 Y1 Z1

set var.materialOpCtrX = move.axes[0].machinePosition
set var.materialOpCtrY = move.axes[1].machinePosition
set var.safeZ          = move.axes[2].machinePosition

if { exists(params.X) && params.X > 0 }
    set var.materialOpLenX = params.X
else
    M291 P"Enter approximate length of work piece in X (left to right, facing machine). If unsure, guess high." R"Work Piece X?" S5 T0 J1 L10 F{global.xMax - global.xMin}
    set var.materialOpLenX = input

; TODO: Account for global.touchProbeSafeDistanceXY
if { var.materialOpLenX > (global.xMax - global.xMin) }
    abort "Entered X material dimension is larger than work area of machine!"

if { exists(params.Y) && params.Y > 0 }
    set var.materialOpLenY = params.Y
else
    M291 P"Enter approximate length of work piece in Y (front to back, facing machine). If unsure, guess high." R"Work Piece Y?" S5 T0 J1 L10 F{global.yMax - global.yMin}
    set var.materialOpLenY = input

if { var.materialOpLenY > (global.yMax - global.yMin) }
    abort "Entered Y material dimension is larger than work area of machine!"

if { exists(params.I) && params.I > 0 }
    set var.probeDepthRelative = params.I
else
    ; Prompt user for a probe depth for edges
    M291 P"Select probe depth from material surface for edges" R"Probe Depth?" S4 T0 J1 K{"-2mm","-4mm","-6mm","-8mm","-10mm"}
    ; input is the zero index of the option chosen.
    ; So we need to add 1, and then multiply by 2 to get the
    ; actual value in MM (absolute).
    ; NOTE: This _must_ be enclosed in {} because * has special meaning in gcode!
    set var.probeDepthRelative = { input + 1 * 2 }

M118 P0 L2 S{"Probing material surface at X=" ^ var.materialOpCtrX ^ ", Y=" ^ var.materialOpCtrY ^ " safe Z=" ^ move.axes[2].machinePosition }

; Probe material surface multiple times and average.
; Use the current Z position as safe since we know the user moved the probe there
; manually.
G6012 X{var.materialOpCtrX} Y{var.materialOpCtrY} S{var.safeZ} B{global.touchProbeRepeatZ} K{global.touchProbeID} C{global.touchProbeNumProbes} V{global.touchProbeProbeSpeed}

set var.materialZ = global.probeCoordinateZ

; TODO: Do we actually need this? We already treat the user jog position
; Z height as safe, so using the actual material surface with an offset
; is potentially redundant
set var.safeZ     = var.materialZ + global.touchProbeSafeDistanceZ
var probeDepth    = var.materialZ - var.probeDepthRelative

; Report material co-ordinates in Z
M118 P0 L2 S{"Material Surface Z=" ^ var.materialZ}

M118 P0 L2 S{"Probing material edges on X at Z=" ^ var.probeDepth ^ "..."}

; Probe from xMin towards opCtrX at current Y position. Move to a safe Z height before moving laterally.
G6010 X{var.materialOpCtrX - global.materialOpLenX/2 - global.touchProbeSafeDistanceXY} D{var.materialOpCtrX} Y{var.materialOpCtrY} Z{var.probeDepth} S{var.safeZ}

set var.materialX1 = global.touchProbeCoordinateX
M118 P0 L2 S{"Material Edge X1=" ^ var.materialX1}

; Probe from xMax towards opCtrX at current Y position. Move to a safe Z height before moving laterally. 
G6010 X{var.materialOpCtrX + global.materialOpLenX/2 + global.touchProbeSafeDistanceXY} D{var.materialOpCtrX} Y{var.materialOpCtrY} Z{var.probeDepth} S{var.safeZ}

set var.materialX2 = global.touchProbeCoordinateX
M118 P0 L2 S{"Material Edge X2=" ^ var.materialX2}

; Find center of work piece in X axis
set var.materialCtrX = {(var.materialX1 + var.materialX2) / 2}

M118 P0 L2 S{"Probing material edges on Y at Z=" ^ var.probeDepth ^ "..."}

; Probe from yMin towards opCtrY at calculated middle of work piece. Move to a safe Z height before moving laterally. 
G6011 Y{global.materialOpCtrY - global.materialOpLenY/2 - global.touchProbeSafeDistanceXY} D{var.materialOpCtrY} X{var.materialCtrX} Z{var.probeDepth} S{var.safeZ}

set var.materialY1 = global.touchProbeCoordinateY
M118 P0 L2 S{"Material Edge Y1=" ^ var.materialY1}

; Probe from yMax towards opCtrY at current Y position. Move to a safe Z height before moving laterally. 
G6011 Y{global.materialOpCtrY + global.materialOpLenY/2 + global.touchProbeSafeDistanceXY} D{var.materialOpCtrY} X{var.materialCtrX} Z{var.probeDepth} S{var.safeZ}

set var.materialY2 = global.touchProbeCoordinateY

M118 P0 L2 S{"Material Edge Y2=" ^ var.materialY2}

set var.materialCtrY = {(var.materialY1 + var.materialY2) / 2}

; At this point we have the X, Y and Z limits of the stock. We can calculate the WCS offset for any obvious point,
; assuming that the corners are at right angles.
; We always use the _top_ surface of the work piece for Z=0 because we can't probe anything else.
M118 P0 L2 S{"WCS Zero Front Left, Top is X=" ^ var.materialX1 ^ ", Y=" ^ var.materialY1 ^ ", Z=" ^ var.materialZ}
M118 P0 L2 S{"WCS Zero Front Right, Top is X=" ^ var.materialX2 ^ ", Y=" ^ var.materialY1 ^ ", Z=" ^ var.materialZ}
M118 P0 L2 S{"WCS Zero Rear Left, Top is X=" ^ var.materialX1 ^ ", Y=" ^ var.materialY2 ^ ", Z=" ^ var.materialZ}
M118 P0 L2 S{"WCS Zero Rear Right, Top is X=" ^ var.materialX2 ^ ", Y=" ^ var.materialY2 ^ ", Z=" ^ var.materialZ}
M118 P0 L2 S{"WCS Zero Centre, Top is X=" ^ var.materialCtrX ^ ", Y=" ^ var.materialCtrY ^ ", Z=" ^ var.materialZ}

M118 P0 L2 S{"Material size is " ^ var.materialX2 - var.materialX1 ^ "mm in X and " ^ var.materialY2 - var.materialY1 ^ "mm in Y" }

var wcsZeroSet = false

; Use absolute positions for movements to corners
G90

M118 P0 L2 S{"Moving " ^ global.touchProbeSafeDistanceZ ^ "mm above Centre"}
G53 G0 X{var.materialCtrX} Y{var.materialCtrY} Z{var.materialZ + global.touchProbeSafeDistanceZ}

; Loop until broken
while true

    ;TODO: Move this _before_ X/Y?, so we only have to probe 2 edges (unless we want WCS Zero at the center)

    ; Prompt user for WCS position.
    M291 P"Move to position?" R"Position" S4 T0 J1 K{"FL","FR","RL","RR","CTR"}
    var movePosition = input

    if var.movePosition == 0
        M118 P0 L2 S{"Moving " ^ global.touchProbeSafeDistanceZ ^ "mm above Front Left"}
        G53 G0 X{var.materialX1} Y{var.materialY1}
    elif var.movePosition == 1
        M118 P0 L2 S{"Moving " ^ global.touchProbeSafeDistanceZ ^ "mm above Front Right"}
        G53 G0 X{var.materialX2} Y{var.materialY1}
    elif var.movePosition == 2
        M118 P0 L2 S{"Moving " ^ global.touchProbeSafeDistanceZ ^ "mm above Rear Left"}
        G53 G0 X{var.materialX1} Y{var.materialY2}
    elif var.movePosition == 3
        M118 P0 L2 S{"Moving " ^ global.touchProbeSafeDistanceZ ^ "mm above Rear Right"}
        G53 G0 X{var.materialX2} Y{var.materialY2}
    elif var.movePosition == 4
        M118 P0 L2 S{"Moving " ^ global.touchProbeSafeDistanceZ ^ "mm above Centre"}
        G53 G0 X{var.materialCtrX} Y{var.materialCtrY}
    else
        abort "Unknown position input " ^ var.movePosition ^ "!"

    ; Confirm zero position and choose WCS number to zero
    M291 P"Use current position, -" ^ global.touchProbeSafeDistanceZ ^ "mm as Zero? Pick WCS" S4 T0 J1 K{"G54","G55","G56","G57","G58","G59","G59.1","G59.2","G59.3"}
    var wcsNumber = input

    ; Zero the selected WCS to current X/Y position at material height.
    ; G10 L20 _subtracts_ co-ordinates from the current position so our
    ; Z value needs to be positive to move the zero point _down_, closer
    ; to the material.
    G10 L20 P{var.wcsNumber+1} X0 Y0 Z{global.touchProbeSafeDistanceZ}

    ; Sleep just in case of hotloop
    G4 P100

    ; We now know the position of Z=0 _as probed by the touch probe_.
    ; We do not know probe stickout, but this does not matter since we
    ; know the height of the activation point of the toolsetter.
    ; When we probe the length of a REAL tool, we are expecting to trigger
    ; the toolsetter at a particular height (Reference Z plus toolsetter height).
    ; We can calculate the tool offset by subtracting the expected Z from the
    ; actual Z, which gives us the difference in length between our touch probe
    ; and the current tool (i.e. how far and in which direction to offset the 
    ; new tool to still touch Z=0 with it after WCS zeroing).

    break

; Park
G27 C1
