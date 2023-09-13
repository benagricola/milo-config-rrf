; G6001.g
; Probe a corner in X and Y by detecting Z and then moving out
; by a given distance to probe the corner from X and Y.
; Allow WCS Zero to be set on given
; corner.
;
; USAGE: "G6001.1"
; PARAMS:
;   C<corner-index-to-probe> 
;   D<probe-dist-from-edge-xy> 
;   I<probe-height-below-surface>
;   W<wcs-index-to-set-probed-origin>
;
; NOTE: MUST be used with a negative Z (so 0 to -<n> rather than 0 to <n>)

M5       ; stop spindle just in case
G21      ; Switch to mm

; Variables used to store material position references. All absolute
var safeZ                 = null ; Known safe height for moves, Z
var materialZ             = null ; Probed surface of material, Z
var materialOpCornerX     = null ; User-specified co-ordinate inwards of corner in X
var materialOpCornerY     = null ; User-specified co-ordinate inwards of corner in Y
var materialCornerX       = null ; Probed co-ordinate of corner in X
var materialCornerY       = null ; Probed co-ordinate of corner in Y
var probeCornerDistanceXY = null ; How far away from the corner we will move before probing
var probeDepthRelative    = null ; Depth below work piece surface to probe edges
var probeCorner           = null ; Corner probing type
var wcsNumber             = null ; WCS Zero to set

; Offsets from operator chosen "corner" to probe inwards from
var startPosX         = 0
var startPosY         = 0

; Confirm touch probe available and connected
G6999

; Check all required parameters
if { !exists(param.C) || param.C < 0 || param.C > #global.originCorners }
    abort { "Must specify corner to probe (FL:0, FR:1, RL:2, RR:3)" }

if { !exists(param.I) || param.I < 1 }
    abort {"Must specify probe depth below material surface (I...) to probe edges at!" }

if { !exists(param.D) }
    abort {"Must specify distance to move outwards (D...) before probing corner edges!" }

elif { param.D <= global.touchProbeRadius }
    abort { "Probing distance " ^ param.D ^ " must be greater than touch probe radius " ^ global.touchProbeRadius }

if { !exists(param.W) }
    abort {"Must specify WCS number (W...) to zero on selected corner!" }


set var.probeCorner           = param.C
set var.probeCornerDistanceXY = param.D
set var.probeDepthRelative    = param.I
set var.wcsNumber             = param.W

; Park, request center of X and Y as this is
; likely close to where the user needs to jog to.
G27 C1

; Start probing sequence
M291 P"Install touch probe in spindle and confirm it is plugged in!" R"Installation check" S3

; Ask the operator to move the touch probe above the corner that needs probing
; Allow Z movement because it can be hard to see exactly where the probe is in X
; and Y if it is too far from the material.
M291 P{"Jog the Touch Probe above the " ^ global.originCorners[var.probeCorner] ^ " corner"} R"Jog to corner" S3 X1 Y1 Z1

set var.materialOpCornerX = move.axes[0].machinePosition
set var.materialOpCornerY = move.axes[1].machinePosition
set var.safeZ             = move.axes[2].machinePosition

if var.probeCorner == 0
    set var.startPosX    = var.materialOpCornerX-var.probeCornerDistanceXY
    set var.startPosY    = var.materialOpCornerY-var.probeCornerDistanceXY
elif var.probeCorner == 1
    set var.startPosX    = var.materialOpCornerX+var.probeCornerDistanceXY
    set var.startPosY    = var.materialOpCornerY-var.probeCornerDistanceXY
elif var.probeCorner == 2
    set var.startPosX    = var.materialOpCornerX-var.probeCornerDistanceXY
    set var.startPosY    = var.materialOpCornerY+var.probeCornerDistanceXY
elif var.probeCorner == 3
    set var.startPosX    = var.materialOpCornerX+var.probeCornerDistanceXY
    set var.startPosY    = var.materialOpCornerY+var.probeCornerDistanceXY
else
    abort { "G6001.1: Unknown probe corner " ^ var.probeCorner ^ "!" }

if { var.startPosX > global.xMax || var.startPosX < global.xMin || var.startPosY > global.yMax || var.startPosY < global.yMin }
    abort { "G6001.1: Edge probing locations are outside of the machine work area. Jog to closer to the corner or set the probing distance (D...) lower!" }

M118 P0 L2 S{"Probing material surface at X=" ^ var.materialOpCornerX ^ ", Y=" ^ var.materialOpCornerY ^ " safe Z=" ^ var.safeZ }

; Probe material surface multiple times and average.
; Use the current Z position as safe since we know the user moved the probe there
; manually.
G6012 X{var.materialOpCornerX} Y{var.materialOpCornerY} S{var.safeZ} B{global.touchProbeRepeatZ} K{global.touchProbeID} C{global.touchProbeNumProbes} V{global.touchProbeProbeSpeed}

set var.materialZ = global.probeCoordinateZ
var probeDepth    = var.materialZ - var.probeDepthRelative

; Report material co-ordinates in Z
M118 P0 L2 S{"Material Surface Z=" ^ var.materialZ}

; Probe X
M118 P0 L2 S{"Probing material edges on X at Z=" ^ var.probeDepth ^ "..."}

; Probe from startPosX towards opCornerX at given Y position. Move to a safe Z height before moving laterally.
G6010 X{var.startPosX} D{var.materialOpCornerX} Y{var.materialOpCornerY} Z{var.probeDepth} S{var.safeZ}

set var.materialCornerX = global.touchProbeCoordinateX
M118 P0 L2 S{"Corner X=" ^ var.materialCornerX}

; Probe Y
M118 P0 L2 S{"Probing material edges on Y at Z=" ^ var.probeDepth ^ "..."}

; Probe from startPosX towards opCornerX at given Y position. Move to a safe Z height before moving laterally.
G6011 Y{var.startPosY} D{var.materialOpCornerY} X{var.materialOpCornerX} Z{var.probeDepth} S{var.safeZ}

set var.materialCornerY = global.touchProbeCoordinateY
M118 P0 L2 S{"Corner Y=" ^ var.materialCornerY}

; At this point we have the X, Y and Z limits of the stock at the given corner.

if { global.confirmUnsafeMove }
    M291 P{"Move " ^ var.safeZ ^ "mm above corner position?"} R"Safety check" S3

; Use absolute positions for movements to corners
G90

; Move across to corner
G53 G0 X{var.materialCornerX} Y{var.materialCornerY}

; Move down to safe distance above corner
G53 G0 Z{var.safeZ}

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

; Park
G27 C1
