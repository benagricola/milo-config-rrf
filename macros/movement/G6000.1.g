; G6001.1.g
; Probe cuboid work piece outer dimensions from X and Y boundaries
; and allow selection of each top corner as WCS Zero.
;
; USAGE: "G6001"
; PARAMS:
;   X<approx-length-of-workpiece-in-x>
;   Y<approx-length-of-workpiece-in-y>
;   I<probe-height-below-surface>
;   W<wcs-index-to-set-probed-origin>

; NOTE: MUST be used with a negative Z (so 0 to -<n> rather than 0 to <n>)

M5       ; stop spindle just in case
G21      ; Switch to mm

; Variables used to store material position references.
var materialZ          = null        ; Probed surface of material, Z
var safeZ              = null        ; Known safe height for moves, Z
var materialX1         = global.xMin ; Material left edge
var materialX2         = global.xMax ; Material right edge
var materialY1         = global.yMax ; Material front edge
var materialY2         = global.yMin ; Material back edge
var materialCtrX       = null        ; Calculated center of material, X
var materialCtrY       = null        ; Calculated center of material, Y
var materialOpCtrX     = null        ; Operator approximate center of material, X
var materialOpCtrY     = null        ; Operator approximate center of material, Y
var materialOpLenX     = null        ; Operator approximate material length, X
var materialOpLenY     = null        ; Operator approximate material length, Y
var probeDepthRelative = null        ; Depth below material surface to probe edges
var probeZ             = null        ; Actual probe-depth co-ordinate
var wcsNumber          = null        ; WCS Zero to set

; Check all required parameters
if { !exists(param.I) || param.I < 1 }
    abort { "G6000.1: Must specify probe depth below material surface (I...) to probe edges at!" }

if { !exists(param.X) }
    abort { "G6000.1: Must specify approximate length of work piece (X...) before probing can commence!" }

if { !exists(param.Y) }
    abort { "G6000.1: Must specify approximate width of work piece (Y...) before probing can commence!" }

if { !exists(param.W) }
    abort { "G6000.1: Must specify WCS number (W...) to zero on selected corner!" }

if { param.X > (global.xMax - global.xMin) }
    abort { "G6000.1: X material dimension is larger than work area of machine!" }

if { param.Y > (global.yMax - global.yMin) }
    abort { "G6000.1: Y material dimension is larger than work area of machine!" }

; Confirm touch probe available and connected
M7002

set var.probeDepthRelative = param.I
set var.materialOpLenX     = param.X
set var.materialOpLenY     = param.Y
set var.wcsNumber          = param.W

; Offsets from operator position to probe from
var startPosX1         = 0
var startPosY1         = 0
var startPosX2         = 0
var startPosY2         = 0

; Park, request center of X and Y as this is
; likely close to where the user needs to jog to.
G27 C1

; Prompt user to place the touch probe over the work piece
M291 P"Jog the Touch Probe above the approximate centre of the work piece" R"Jog to center" S3 X1 Y1 Z1

set var.materialOpCtrX = move.axes[0].machinePosition
set var.materialOpCtrY = move.axes[1].machinePosition
set var.safeZ          = move.axes[2].machinePosition

M118 P0 L2 S{"Probing material surface at X=" ^ var.materialOpCtrX ^ ", Y=" ^ var.materialOpCtrY ^ " safe Z=" ^ move.axes[2].machinePosition }

; Probe material surface multiple times and average.
; Use the current Z position as safe since we know the user moved the probe there
; manually.
G6012 X{var.materialOpCtrX} Y{var.materialOpCtrY} S{var.safeZ} B{global.touchProbeRepeatZ} K{global.touchProbeID} C{global.touchProbeNumProbes} V{global.probeSpeed}

set var.materialZ = global.probeCoordinateZ

; TODO: Do we actually need this? We already treat the user jog position
; Z height as safe, so using the actual material surface with an offset
; is potentially redundant
set var.probeZ = var.materialZ - var.probeDepthRelative

; Report material co-ordinates in Z
M118 P0 L2 S{"Material Surface Z=" ^ var.materialZ}
M118 P0 L2 S{"Probing material edges on X at Z=" ^ var.probeZ ^ "..."}

set var.startPosX1 = var.materialOpCtrX - var.materialOpLenX/2 - global.touchProbeSafeDistanceXY
set var.startPosX2 = var.materialOpCtrX + var.materialOpLenX/2 + global.touchProbeSafeDistanceXY
set var.startPosY1 = var.materialOpCtrY - var.materialOpLenY/2 - global.touchProbeSafeDistanceXY
set var.startPosY2 = var.materialOpCtrY + var.materialOpLenY/2 + global.touchProbeSafeDistanceXY

; Sanity check this as 2 if statements to avoid ridiculously long lines
if { var.startPosX1 > global.xMax || var.startPosX1 < global.xMin || var.startPosY1 > global.yMax || var.startPosY1 < global.yMin }
    abort { "G6000.1: Edge probing locations are outside of the machine work area. Your work piece is either too big or global.touchProbeSafeDistanceXY is too high!" }

if { var.startPosX2 > global.xMax || var.startPosX2 < global.xMin || var.startPosY2 > global.yMax || var.startPosY2 < global.yMin }
    abort { "G6000.1: Edge probing locations are outside of the machine work area. Your work piece is either too big or global.touchProbeSafeDistanceXY is too high!" }

; TODO: Check for outside machine limits!
; Probe from xMin towards opCtrX at current Y position. Move to a safe Z height before moving laterally.
G6010 X{var.startPosX1} D{var.materialOpCtrX} Y{var.materialOpCtrY} Z{var.probeZ} S{var.safeZ}

set var.materialX1 = global.probeCoordinateX
M118 P0 L2 S{"Material Edge X1=" ^ var.materialX1}

; Probe from xMax towards opCtrX at current Y position. Move to a safe Z height before moving laterally.
G6010 X{var.startPosX2} D{var.materialOpCtrX} Y{var.materialOpCtrY} Z{var.probeZ} S{var.safeZ}

set var.materialX2 = global.probeCoordinateX
M118 P0 L2 S{"Material Edge X2=" ^ var.materialX2}

; Find center of work piece in X axis
set var.materialCtrX = {(var.materialX1 + var.materialX2) / 2}

M118 P0 L2 S{"Probing material edges on Y at Z=" ^ var.probeZ ^ "..."}


; Probe from yMin towards opCtrY at calculated middle of work piece. Move to a safe Z height before moving laterally.
G6011 Y{var.startPosY1} D{var.materialOpCtrY} X{var.materialCtrX} Z{var.probeZ} S{var.safeZ}

set var.materialY1 = global.probeCoordinateY
M118 P0 L2 S{"Material Edge Y1=" ^ var.materialY1}

; Probe from yMax towards opCtrY at current Y position. Move to a safe Z height before moving laterally.
G6011 Y{var.startPosY2} D{var.materialOpCtrY} X{var.materialCtrX} Z{var.probeZ} S{var.safeZ}

set var.materialY2 = global.probeCoordinateY

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

M118 P0 L2 S{"Moving to Z=" ^ var.safeZ ^ "mm above Centre"}

G53 G0 X{var.materialCtrX} Y{var.materialCtrY} Z{var.safeZ}

; Loop until broken
while true
    ; Prompt user for WCS position.
    M291 P"Move to position?" R"Position" S4 T0 J1 K{global.originCorners}
    var movePosition = input

    if var.movePosition == 0
        M118 P0 L2 S{"Moving Z=" ^ var.safeZ ^ "mm above Front Left"}
        G53 G0 X{var.materialX1} Y{var.materialY1}
    elif var.movePosition == 1
        M118 P0 L2 S{"Moving Z=" ^ var.safeZ ^ "mm above Front Right"}
        G53 G0 X{var.materialX2} Y{var.materialY1}
    elif var.movePosition == 2
        M118 P0 L2 S{"Moving Z=" ^ var.safeZ ^ "mm above Rear Left"}
        G53 G0 X{var.materialX1} Y{var.materialY2}
    elif var.movePosition == 3
        M118 P0 L2 S{"Moving Z=" ^ var.safeZ ^ "mm above Rear Right"}
        G53 G0 X{var.materialX2} Y{var.materialY2}
    elif var.movePosition == 4
        M118 P0 L2 S{"Moving Z=" ^ var.safeZ ^ "mm above Centre"}
        G53 G0 X{var.materialCtrX} Y{var.materialCtrY}
    else
        abort { "G6000.1: Unknown position input " ^ var.movePosition ^ "!" }

    ; Material Z and Safe Z are co-ordinates, we are already over the corner
    ; at Z=Safe Z so we need the relative difference between our current
    ; height and the material surface.
    var safeOffsetZ = { abs(var.materialZ) + var.safeZ }

    ; Confirm zero position and choose WCS number to zero
    M291 P{"Use current position, -" ^ var.safeOffsetZ ^ "mm as X=0, Y=0, Z=0 for WCS " ^ var.wcsNumber ^ "?"} S3 T0 J1

    ; Zero the selected WCS to current X/Y position at material height.
    ; G10 L20 _subtracts_ co-ordinates from the current position so our
    ; Z value needs to be positive to move the zero point _down_, closer
    ; to the material.
    ; We moved _above_ the zero point so need to adjust our zero down to it.
    G10 L20 P{var.wcsNumber} X0 Y0 Z{var.safeOffsetZ}

    ; Sleep just in case of hotloop
    G4 P100

    break

; Park
G27
