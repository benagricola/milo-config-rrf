; G6001.g
; Probe a corner in X and Y by detecting Z and then moving out
; by a given distance to probe the corner from X and Y.
; Allow WCS Zero to be set on given
; corner.
;
; USAGE: "G6001"
; OPTIONAL PARAMS:
;   M[0-3] D<probe-dist-from-edge-xy> I<probe-height-below-surface>
;
; NOTE: MUST be used with a negative Z (so 0 to -<n> rather than 0 to <n>)

M5       ; stop spindle just in case

G21      ; Switch to mm

; Variables used to store material position references. All absolute
var safeZ                 = 0 ; Known safe height for moves, Z
var materialZ             = 0 ; Probed surface of material, Z
var materialOpCornerX     = 0 ; User-specified co-ordinate inwards of corner in X
var materialOpCornerY     = 0 ; User-specified co-ordinate inwards of corner in Y
var materialCornerX       = 0 ; Probed co-ordinate inwards of corner in X
var materialCornerY       = 0 ; Probed co-ordinate inwards of corner in Y
var probeCornerDistanceXY = 0 ; How far away from the corner we will move before probing
var probeDepthRelative    = 0 ; Depth below work piece surface to probe edges
var probeCorner           = 0 ; Corner probing type
var probeCorners          = {"FL","FR","RL","RR"} ; Probe corner types

; Offsets from operator chosen "corner" to probe inwards from
var startPosX         = 0
var startPosY         = 0

; Check if touchprobe feature is available
if {!exists(global.featureTouchProbe) || !global.featureTouchProbe }
    ; TODO: Walk user through manual probing process
    abort "Unable to probe material without touch probe!"

; Park, request center of X and Y as this is
; likely close to where the user needs to jog to.
G27 C1

; Start probing sequence
M291 P"Install touch probe in spindle and confirm it is plugged in!" R"Installation check" S3

; Ask user which corner they want to probe if not specified
if { exists(params.M) }
    set var.probeCorner = params.M
else
    ; Prompt user to place the touch probe over the work piece
    ; Allow the user to pick the corner that we're probing

    M291 P"Select corner to probe" R"Select corner" S4 K{"FL","FR","RL","RR"}
    set var.probeCorner = input

if var.probeCorner == 0
    M118 P0 L2 S{"Finding Front Left corner"}
    set var.startPosX    = var.materialOpCornerX-var.probeCornerDistanceXY
    set var.startPosY    = var.materialOpCornerY+var.probeCornerDistanceXY
elif var.probeCorner == 1
    M118 P0 L2 S{"Finding Front Right corner"}
    set var.startPosX    = var.materialOpCornerX+var.probeCornerDistanceXY
    set var.startPosY    = var.materialOpCornerY+var.probeCornerDistanceXY
elif var.probeCorner == 2
    M118 P0 L2 S{"Finding Rear Left corner"}
    set var.startPosX    = var.materialOpCornerX-var.probeCornerDistanceXY
    set var.startPosY    = var.materialOpCornerY-var.probeCornerDistanceXY
elif var.probeCorner == 3
    M118 P0 L2 S{"Finding Rear Right corner"}
    set var.startPosX    = var.materialOpCornerX+var.probeCornerDistanceXY
    set var.startPosY    = var.materialOpCornerY-var.probeCornerDistanceXY
else
    abort "Unknown position input " ^ var.probeCorner ^ "!"

; Ask the operator to move the touch probe above the corner that needs probing
; Allow Z movement because it can be hard to see exactly where the probe is in X
; and Y if it is too far from the material.
M291 P{"Jog the Touch Probe above the corner to probe"} R"Find corner zero" S3 X1 Y1 Z1
set var.materialOpCornerX = move.axes[0].machinePosition
set var.materialOpCornerY = move.axes[1].machinePosition
set var.safeZ             = move.axes[2].machinePosition

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

; Prompt operator for distance from each edge of the corner
; we will probe from, if not already specified as a parameter
; The probe will move _out_ from the operators corner estimate by
; this distance before probing inwards towards the workpiece.
; We give the user the option to specify this as they may be
; trying to probe an internal corner which has very little clearance
; from another piece of the part.
if { exists(params.D) }
    set var.probeCornerDistanceXY = params.D
else
    M291 P"Select how far to probe towards each edge of the corner" R"Corner probing distance" S4 K{"5mm","10mm","15mm","20mm","25mm","30mm"}
    set var.probeCornerDistanceXY = {input+1*5}

; Make sure user doesn't set a probe distance less than the
; radius of the touch probe otherwise we might crash it into
; the work piece when dropping to probing depth.
if { var.probeCornerDistanceXY <= global.touchProbeRadius }
    abort { "Probing distance " ^ var.probeCornerDistanceXY ^ " must be greater than touch probe radius " ^ global.touchProbeRadius }

M118 P0 L2 S{"Probing material surface at X=" ^ var.materialOpCornerX ^ ", Y=" ^ var.materialOpCornerY ^ " safe Z=" ^ var.safeZ }

; Probe material surface multiple times and average.
; Use the current Z position as safe since we know the user moved the probe there
; manually.
G6012 X{var.materialOpCornerX} Y{var.materialOpCornerY} S{var.safeZ} B{global.touchProbeRepeatZ} K{global.touchProbeID} C{global.touchProbeNumProbes} V{global.touchProbeProbeSpeed}

set var.materialZ = global.probeCoordinateZ
set var.safeZ     = var.materialZ + global.touchProbeSafeDistanceZ
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
    M291 P{"Move " ^ global.touchProbeSafeDistanceZ ^ "mm above corner position?"} R"Safety check" S3

; Use absolute positions for movements to corners
G90

; Move across to corner
G53 G0 X{var.materialCornerX} Y{var.materialCornerY}

; Move down to safe distance above corner
G53 G0 Z{var.materialZ + global.touchProbeSafeDistanceZ}

; Confirm zero position and choose WCS number to zero
M291 P"Use current position, -" ^ global.touchProbeSafeDistanceZ ^ "mm as Zero? Pick WCS" S4 T0 J1 K{"G54","G55","G56","G57","G58","G59","G59.1","G59.2","G59.3"}
var wcsNumber = input

; Zero the selected WCS to current X/Y position at material height.
; G10 L20 _subtracts_ co-ordinates from the current position so our
; Z value needs to be positive to move the zero point _down_, closer
; to the material.
; We moved _above_ the zero point so need to adjust our zero down to it.
G10 L20 P{var.wcsNumber+1} X0 Y0 Z{global.touchProbeSafeDistanceZ}

; Park
G27 C1
