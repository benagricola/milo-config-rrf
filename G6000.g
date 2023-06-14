; Probe WCS Zero based on the top and outside surfaces of a work piece.

M5       ; stop spindle just in case

G21      ; Switch to mm

G28      ; home all axes

G27      ; park spindle

; Variables used to store material position references
var referenceZ   = 0
var materialZ    = 0
var safeZ        = 0
var materialX1   = global.xMin
var materialX2   = global.xMax
var materialY1   = global.yMax
var materialY2   = global.yMin
var materialCtrX = 0
var materialCtrY = 0

; Start probing sequence
M291 P"Install touch probe and PLUG IT IN" R"Installation check" S2	

; TODO: Check status of probe in object model to confirm it is connected.

M118 P0 L2 S{"Probing reference surface at X=" ^ global.touchProbeReferenceX ^ ", Y=" ^ global.touchProbeReferenceY }

; Probe reference surface multiple times and average.
G6003 X{global.touchProbeReferenceX} Y{global.touchProbeReferenceY} S{global.minZ + global.touchProbeMaxLength}

set var.referenceZ = global.touchProbeCoordinateZ

M118 P0 L2 S{"Reference Surface Z=" ^ var.referenceZ}

; Park
G27

; Prompt user to place the touch probe over the work piece
M291 P"Jog the Touch Probe above the workpiece" R"Find height of workpiece" S3 X1 Y1

M118 P0 L2 S{"Probing material surface at X=" ^ move.axes[0].machinePosition ^ ", Y=" ^ move.axes[1].machinePosition ^ " safe height S=" ^ move.axes[2].machinePosition }

; Probe material surface multiple times and average.
G6003 X{move.axes[0].machinePosition} Y{move.axes[1].machinePosition} S{move.axes[2].machinePosition}

set var.materialZ = global.touchProbeCoordinateZ
set var.safeZ     = var.materialZ + global.touchProbeSafeDistanceZ

; Report material co-ordinates in Z
M118 P0 L2 S{"Material Surface Z=" ^ var.materialZ}
M118 P0 L2 S{"Material Height =" ^ var.referenceZ - var.materialZ}

; Prompt user for a probe depth for edges
M291 P"Probe depth for edges?" S4 T0 K{"-2mm","-4mm","-6mm","-8mm","-10mm"}

; probeDepthRelative is the _index_ of the option chosen, which happens to be
; half of the expected value (idx 1 = 2mm offset etc)

var probeDepthRelative = input
set var.probeDepth = var.materialZ - abs(var.probeDepthRelative*2)

M118 P0 L2 S"Probing material edges on X at Z=" ^ var.probeDepth ^ "..."

; Probe from xMin towards xMax at current Y position. Move to a safe Z height before moving laterally. 
G6001 X={global.xMin} D={global.xMax} Y={move.axes[1].machinePosition} Z={var.probeDepth} S={var.safeZ}

set var.materialX1 = global.touchProbeCoordinateX
M118 P0 L2 S{"Material Edge X1=" ^ var.materialX1}

; Probe from xMax towards xMin at current Y position. Move to a safe Z height before moving laterally. 
G6001 X={global.xMax} D={global.xMin} Y={move.axes[1].machinePosition} Z={var.probeDepth} S={var.safeZ}

set var.materialX2 = global.touchProbeCoordinateX
M118 P0 L2 S{"Material Edge X2=" ^ var.materialX1}

; Find center of work piece in X axis
set var.materialCtrX = (var.materialX1 + var.materialX2) / 2

M118 P0 L2 S"Probing material edges on Y at Z=" ^ var.probeDepth ^ "..."

; Probe from yMin towards yMax at calculated middle of work piece. Move to a safe Z height before moving laterally. 
G6001 Y={global.yMin} D={global.yMax} X={var.materialCtrX} Z={var.probeDepth} S={var.safeZ}

set var.materialY1 = global.touchProbeCoordinateY
M118 P0 L2 S{"Material Edge Y1=" ^ var.materialY1}

; Probe from yMax towards yMin at current Y position. Move to a safe Z height before moving laterally. 
G6001 Y={global.yMax} D={global.yMin} X={var.materialCtrY} Z={var.probeDepth} S={var.safeZ}

set var.materialY2 = global.touchProbeCoordinateY
M118 P0 L2 S{"Material Edge Y2=" ^ var.materialY2}

set var.materialCtrY = (var.materialY1 + var.materialY2) / 2

; Probing complete, Park
G27

; At this point we have the X, Y and Z limits of the stock. We can calculate the WCS offset for any obvious point.
; Note: "Material height" uses the reference surface for calculation, as we can't probe the bottom corner of a part.
; This is why we always use the _top_ surface of the work piece for Z=0.

M118 P0 L2 S{"WCS Zero Front Left, Top is X=" ^ var.materialX1 ^ ", Y=" ^ var.materialY2 ^ ", Z=" ^ var.materialZ }
M118 P0 L2 S{"WCS Zero Front Right, Top is X=" ^ var.materialX2 ^ ", Y=" ^ var.materialY2 ^ ", Z=" ^ var.materialZ }
M118 P0 L2 S{"WCS Zero Back Left, Top is X=" ^ var.materialX1 ^ ", Y=" ^ var.materialY1 ^ ", Z=" ^ var.materialZ }
M118 P0 L2 S{"WCS Zero Back Right, Top is X=" ^ var.materialX2 ^ ", Y=" ^ var.materialY1 ^ ", Z=" ^ var.materialZ }
M118 P0 L2 S{"WCS Zero Centre, Top is X=" ^ var.materialCtrX ^ ", Y=" ^ var.materialCtrY ^ ", Z=" ^ var.materialZ }

; Prompt user for WCS position.
M291 P"Choose WCS Zero Position. Front is closest to operator." S4 T0 K{"Front Left, Top","Front Right, Top","Back Left, Top","Back Right, Top","Centre, Top"}
var wcsPosition = input

; TODO: Move above selected WCS position, prompt user if zero looks correct, and then apply. Re-park.
; Adjust Z=0 for height of touch probe, based on Z position of reference surface and its' distance from
; toolsetter activation point.

if wcsPosition == 1
    M118 P0 L2 S{"WCS Zero Front Left, Top is X=" ^ var.materialX1 ^ ", Y=" ^ var.materialY2 ^ ", Z=" ^ var.materialZ }
elif wcsPosition == 2
    M118 P0 L2 S{"WCS Zero Front Right, Top is X=" ^ var.materialX2 ^ ", Y=" ^ var.materialY2 ^ ", Z=" ^ var.materialZ }
elif wcsPosition == 3
    M118 P0 L2 S{"WCS Zero Back Left, Top is X=" ^ var.materialX1 ^ ", Y=" ^ var.materialY1 ^ ", Z=" ^ var.materialZ }
elif wcsPosition == 4
    M118 P0 L2 S{"WCS Zero Back Right, Top is X=" ^ var.materialX2 ^ ", Y=" ^ var.materialY1 ^ ", Z=" ^ var.materialZ }
elif wcsPosition == 5
    M118 P0 L2 S{"WCS Zero Centre, Top is X=" ^ var.materialCtrX ^ ", Y=" ^ var.materialCtrY ^ ", Z=" ^ var.materialZ }
else
    abort "Unknown WCS position input " ^ wcsPosition ^ "!"



