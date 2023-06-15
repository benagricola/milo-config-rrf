; Probe WCS Zero based on the top and outside surfaces of a work piece.

; NOTE: MUST be used with a negative Z (so 0 to -<n> rather than 0 to <n>)

M5       ; stop spindle just in case

G21      ; Switch to mm

G28      ; home all axes

G27      ; park spindle

; Variables used to store material position references. All absolute
var referenceZ     = 0           ; Probed reference surface, Z
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

; Start probing sequence
M291 P"Install touch probe and PLUG IT IN" R"Installation check" S2	

; TODO: Check status of probe in object model to confirm it is connected.

M118 P0 L2 S{"Probing ref. surface at X=" ^ global.touchProbeReferenceX ^ ", Y=" ^ global.touchProbeReferenceY }

; Probe reference surface multiple times and average.
; Retract spindle fully for safe moves
G6003 X{global.touchProbeReferenceX} Y{global.touchProbeReferenceY} S{global.zMax}

set var.referenceZ = global.touchProbeCoordinateZ

M118 P0 L2 S{"Reference Surface Z=" ^ var.referenceZ}

; Park
G27

; Prompt user to place the touch probe over the work piece
M291 P"Jog the Touch Probe above the workpiece" R"Find height of workpiece" S3 X1 Y1

set var.materialOpCtrX = move.axes[0].machinePosition
set var.materialOpCtrY = move.axes[1].machinePosition

M118 P0 L2 S{"Probing material surface at X=" ^ var.materialOpCtrX ^ ", Y=" ^ var.materialOpCtrY ^ " safe Z=" ^ move.axes[2].machinePosition }

; Probe material surface multiple times and average.
; Use the current Z position as safe since we know the user moved the probe there
; manually.
G6003 X{var.materialOpCtrX} Y{var.materialOpCtrY} S{move.axes[2].machinePosition}

set var.materialZ = global.touchProbeCoordinateZ
set var.safeZ     = var.materialZ + global.touchProbeSafeDistanceZ

; Report material co-ordinates in Z
M118 P0 L2 S{"Material Surface Z=" ^ var.materialZ}
M118 P0 L2 S{"Material Height =" ^ var.referenceZ - var.materialZ}

; Prompt user for a probe depth for edges
M291 P"Select probe depth from material surface for edges" R"Probe Depth?" S4 T0 K{"-2mm","-4mm","-6mm","-8mm","-10mm"}
var probeDepthRelative = input

M118 P0 L2 S"Probe depth selection value: " ^ var.probeDepthRelative ^ "..."

; probeDepthRelative is the _index_ of the option chosen, which happens to be
; half of the expected value (idx 1 = 2mm offset etc)

var probeDepth = var.materialZ - var.probeDepthRelative*2

M118 P0 L2 S"Probing material edges on X at Z=" ^ var.probeDepth ^ "..."

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

M118 P0 L2 S"Probing material edges on Y at Z=" ^ var.probeDepth ^ "..."

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
G27

; At this point we have the X, Y and Z limits of the stock. We can calculate the WCS offset for any obvious point.
; Note: "Material height" uses the reference surface for calculation, as we can't probe the bottom corner of a part.
; This is why we always use the _top_ surface of the work piece for Z=0.

M118 P0 L2 S{"WCS Zero Front Left, Top is X=" ^ var.materialX1 ^ ", Y=" ^ var.materialY2 ^ ", Z=" ^ var.materialZ}
M118 P0 L2 S{"WCS Zero Front Right, Top is X=" ^ var.materialX2 ^ ", Y=" ^ var.materialY2 ^ ", Z=" ^ var.materialZ}
M118 P0 L2 S{"WCS Zero Back Left, Top is X=" ^ var.materialX1 ^ ", Y=" ^ var.materialY1 ^ ", Z=" ^ var.materialZ}
M118 P0 L2 S{"WCS Zero Back Right, Top is X=" ^ var.materialX2 ^ ", Y=" ^ var.materialY1 ^ ", Z=" ^ var.materialZ}
M118 P0 L2 S{"WCS Zero Centre, Top is X=" ^ var.materialCtrX ^ ", Y=" ^ var.materialCtrY ^ ", Z=" ^ var.materialZ}

;TODO: Move this _before_ probing, so we only have to probe 2 edges (unless we want WCS Zero at the center)

; Prompt user for WCS position.
M291 P"Choose WCS Zero Position, from operator perspective." S4 T0 K{"Front Left, Top","Front Right, Top","Back Left, Top","Back Right, Top","Centre, Top"}
var wcsPosition = input

; Move above chosen WCS zero
G90

if wcsPosition == 1
    M118 P0 L2 S{"Moving " ^ global.touchProbeSafeDistanceZ ^ "mm above Front Left"}
    G53 G0 X{var.materialX1} Y{var.materialY2}
    G53 G0 Z{var.materialZ + global.touchProbeSafeDistanceZ}
elif wcsPosition == 2
    M118 P0 L2 S{"Moving " ^ global.touchProbeSafeDistanceZ ^ "mm above Front Right"}
    G53 G0 X{var.materialX2} Y{var.materialY2}
    G53 G0 Z{var.materialZ + global.touchProbeSafeDistanceZ}
elif wcsPosition == 3
    M118 P0 L2 S{"Moving " ^ global.touchProbeSafeDistanceZ ^ "mm above Back Left"}
    G53 G0 X{var.materialX1} Y{var.materialY1}
    G53 G0 Z{var.materialZ + global.touchProbeSafeDistanceZ}
elif wcsPosition == 4
    M118 P0 L2 S{"Moving " ^ global.touchProbeSafeDistanceZ ^ "mm above Back Right"}
    G53 G0 X{var.materialX2} Y{var.materialY1}
    G53 G0 Z{var.materialZ + global.touchProbeSafeDistanceZ}
elif wcsPosition == 5
    M118 P0 L2 S{"Moving " ^ global.touchProbeSafeDistanceZ ^ "mm above Centre"}
    G53 G0 X{var.materialCtrX} Y{var.materialCtrY}
    G53 G0 Z{var.materialZ + global.touchProbeSafeDistanceZ}
else
    abort "Unknown WCS position input " ^ wcsPosition ^ "!"

; Confirm Zero position
M291 P{ "Positioned " ^ global.touchProbeSafeDistanceZ ^ "mm above calculated WCS Zero. Confirm?"} S3 T0 R"Confirm WCS Zero"

; Choose WCS number to zero
M291 P"Choose WCS to Zero" S4 T0 K{"G54","G55","G56","G57","G58","G59","G59.1","G59.2","G59.3"}
var wcsNumber = input

; Zero the selected WCS to current X/Y position at material height.
G10 L20 P{wcsNumber} X0 Y0 Z{-global.touchProbeSafeDistanceZ}

; Park
G27
