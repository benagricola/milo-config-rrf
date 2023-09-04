; G6000
; Probe WCS Zero based on the top and outside surfaces of a work piece.
;
; USAGE: "G6000"
;
; NOTE: MUST be used with a negative Z (so 0 to -<n> rather than 0 to <n>)

M5       ; stop spindle just in case

G21      ; Switch to mm

G27      ; park spindle

; Variables used to store material position references. All absolute
var materialZ      = 0           ; Probed surface of material, Z
var safeZ          = 0           ; Known safe height for moves, Z
var materialX1     = global.xMin ; Material left edge
var materialX2     = global.xMax ; Material right edge
var materialY1     = global.yMax ; Material front edge
var materialY2     = global.yMin ; Material back edge
var materialCtrX   = 0           ; Calculated center of material, X
var materialCtrY   = 0           ; Calculated center of material, Y
var materialOpCtrX = 0           ; Operator approximate center of material, X
var materialOpCtrY = 0           ; Operator approximate center of material, Y

; Check if touchprobe feature is available
if {!exists(global.featureTouchProbe) || !global.featureTouchProbe }
    ; TODO: Walk user through manual probing process
    abort "Unable to probe material without touch probe!"

; Start probing sequence
M291 P"Install touch probe and confirm it is plugged in!" R"Installation check" S3

; TODO: Check status of probe in object model to confirm it is connected.

; Park, request center of X and Y as this is
; likely close to where the user needs to jog to.
G27 C1

; Prompt user to place the touch probe over the work piece
M291 P"Jog the Touch Probe above the approximate centre of the workpiece" R"Find height of workpiece" S3 X1 Y1

set var.materialOpCtrX = move.axes[0].machinePosition
set var.materialOpCtrY = move.axes[1].machinePosition

M118 P0 L2 S{"Probing material surface at X=" ^ var.materialOpCtrX ^ ", Y=" ^ var.materialOpCtrY ^ " safe Z=" ^ move.axes[2].machinePosition }

; Probe material surface multiple times and average.
; Use the current Z position as safe since we know the user moved the probe there
; manually.
G6003 X{var.materialOpCtrX} Y{var.materialOpCtrY} S{move.axes[2].machinePosition} B{global.touchProbeDistanceZ} K{global.touchProbeID} C{global.touchProbeNumProbes} A{global.touchProbeProbeSpeed}

set var.materialZ = global.probeCoordinateZ
set var.safeZ     = var.materialZ + global.touchProbeSafeDistanceZ


; Report material co-ordinates in Z
M118 P0 L2 S{"Material Surface Z=" ^ var.materialZ}

; Prompt user for a probe depth for edges
M291 P"Select probe depth from material surface for edges" R"Probe Depth?" S4 T0 J1 K{"-2mm","-4mm","-6mm","-8mm","-10mm"}
var probeDepthRelative = input

; probeDepthRelative is the zero index of the option chosen.
; So we need to add 1, and then multiply by 2 to get the
; actual value in MM (absolute).

; NOTE: This _must_ be enclosed in {} because * has special meaning in gcode!
var probeDepth = { var.materialZ - (var.probeDepthRelative+1*2) }

M118 P0 L2 S{"Probing material edges on X at Z=" ^ var.probeDepth ^ "..."}

; Probe from xMin towards opCtrX at current Y position. Move to a safe Z height before moving laterally. 
G6001 X{global.xMin} D{var.materialOpCtrX} Y{var.materialOpCtrY} Z{var.probeDepth} S{var.safeZ}

set var.materialX1 = global.touchProbeCoordinateX
M118 P0 L2 S{"Material Edge X1=" ^ var.materialX1}

; Probe from xMax towards opCtrX at current Y position. Move to a safe Z height before moving laterally. 
G6001 X{global.xMax} D{var.materialOpCtrX} Y{var.materialOpCtrY} Z{var.probeDepth} S{var.safeZ}

set var.materialX2 = global.touchProbeCoordinateX
M118 P0 L2 S{"Material Edge X2=" ^ var.materialX1}

; Find center of work piece in X axis
set var.materialCtrX = {(var.materialX1 + var.materialX2) / 2}

M118 P0 L2 S{"Probing material edges on Y at Z=" ^ var.probeDepth ^ "..."}

; Probe from yMin towards opCtrY at calculated middle of work piece. Move to a safe Z height before moving laterally. 
G6002 Y{global.yMin} D{var.materialOpCtrY} X{var.materialCtrX} Z{var.probeDepth} S{var.safeZ}

set var.materialY1 = global.touchProbeCoordinateY
M118 P0 L2 S{"Material Edge Y1=" ^ var.materialY1}

; Probe from yMax towards opCtrY at current Y position. Move to a safe Z height before moving laterally. 
G6002 Y{global.yMax} D{var.materialOpCtrY} X{var.materialCtrX} Z{var.probeDepth} S{var.safeZ}

set var.materialY2 = global.touchProbeCoordinateY

M118 P0 L2 S{"Material Edge Y2=" ^ var.materialY2}

set var.materialCtrY = {(var.materialY1 + var.materialY2) / 2}

; Probing complete, Park
G27 C1

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

; Loop until broken
while true

    ;TODO: Move this _before_ X/Y?, so we only have to probe 2 edges (unless we want WCS Zero at the center)

    ; Prompt user for WCS position.
    M291 P"Move to position?" R"Position" S4 T0 J1 K{"FL","FR","RL","RR","CTR"}
    var movePosition = input

    if var.movePosition == 0
        M118 P0 L2 S{"Moving " ^ global.touchProbeDistanceZ ^ "mm above Front Left"}
        G53 G0 X{var.materialX1} Y{var.materialY1}
    elif var.movePosition == 1
        M118 P0 L2 S{"Moving " ^ global.touchProbeDistanceZ ^ "mm above Front Right"}
        G53 G0 X{var.materialX2} Y{var.materialY1}
    elif var.movePosition == 2
        M118 P0 L2 S{"Moving " ^ global.touchProbeDistanceZ ^ "mm above Rear Left"}
        G53 G0 X{var.materialX1} Y{var.materialY2}
    elif var.movePosition == 3
        M118 P0 L2 S{"Moving " ^ global.touchProbeDistanceZ ^ "mm above Rear Right"}
        G53 G0 X{var.materialX2} Y{var.materialY2}
    elif var.movePosition == 4
        M118 P0 L2 S{"Moving " ^ global.touchProbeDistanceZ ^ "mm above Centre"}
        G53 G0 X{var.materialCtrX} Y{var.materialCtrY}
    else
        abort "Unknown position input " ^ var.movePosition ^ "!"

    G53 G0 Z{var.materialZ + global.touchProbeDistanceZ}

    ; Confirm Zero position
    M291 P{"Use current position, -" ^ global.touchProbeDistanceZ ^ "mm as WCS Zero?"} R"Confirm WCS Zero" S4 T0 J1 K{"Yes","No"} X1 Y1 Z1

    ; If operator selected no, allow selection of another position
    if input == 1
        continue

    ; Choose WCS number to zero
    M291 P"Choose WCS to Zero" S4 T0 J1 K{"G54","G55","G56","G57","G58","G59","G59.1","G59.2","G59.3"}
    var wcsNumber = input

    ; Zero the selected WCS to current X/Y position at material height.
    ; G10 L20 _subtracts_ co-ordinates from the current position so our
    ; Z value needs to be positive to move the zero point _down_, closer
    ; to the material.
    G10 L20 P{var.wcsNumber+1} X0 Y0 Z{global.touchProbeDistanceZ}

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
