; G6002: Repeatable edge (horizontal) probe, Y axis

; Assume probe is clear to move in X/Y to starting position,
; then plunge to Z starting position.

; Switch to mm
G21

var retries         = 0
var probePos        = 0
var curPos          = 0
var backoffPos      = global.touchProbeDistanceXY
var probeRadiusComp = -global.touchProbeRadius

if { !exists(param.D) || param.D == 0 }
    { abort "Must provide direction and distance (D=+-...) you want to probe in!" }

if { !exists(param.X) || !exists(param.Y) || !exists(param.Z) }
    { abort "Must provide starting position (X=, Y=, Z=)!" }

if param.D == param.Y
    { abort "Parameters Y= and D= cannot be the same!" }

if { !exists(param.S) }
    { abort "Must provide a safe height (S=) to retreat to after probing for subsequent moves!" }

if global.probeConfirmMove
    M291 P{"Move to X=" ^ param.X ^ ", Y=" ^ param.Y ^ " at safe Z=" ^ param.S ^ ", down towards Z=" ^ param.Z ^ " and probe Y=" ^ param.D ^ "?"} R"Safety check" S3

; Absolute moves to find starting position
G90

; Move to safe height
G53 G0 Z{param.S}

; Move to starting position
G53 G0 X{param.X} Y{param.Y}

; Move down to probe height
G53 G0 Z{param.Z}

; Back to relative moves for probing
G91

; If moving in a positive direction, back off in negative
; Compensate for probe width in positive (when probe touches
; surface, it is at an X co-ordinate LESS than where the actual
; surface is, by the radius of the probe).
if { param.Y < param.D }
    set var.backoffPos      = -var.backoffPos
    set var.probeRadiusComp = { abs(var.probeRadiusComp) }

while var.retries <= global.touchProbeNumProbes
    ; Probe towards surface
    G53 G38.2 Y{param.D} K{global.touchProbeID}
    
    ; Record current position
    set var.curPos = move.axes[1].machinePosition

    ; Move away from the trigger point
    G53 G0 Y{var.backoffPos}

    ; If this is not the initial rough probe, record the position
    if var.retries > 0
        ; Add probe position for averaging
        set var.probePos = var.probePos+var.curPos

        M118 P0 L2 S{"Touch Probe " ^ var.retries ^ "/" ^ global.touchProbeNumProbes ^ ": Y=" ^ var.curPos}

    else
        ; Otherwise, reduce the probe speed to increase accuracy
        M203 Y{global.touchProbeProbeSpeed}

    ; Dwell so machine can settle
    G4 P{global.touchProbeDwellTime}

    ; Iterate retry counter
    set var.retries = var.retries + 1

; Reset all speed limits after probing
M98 P"speed.g"

var probePosAveraged = var.probePos / global.touchProbeNumProbes

M118 P0 L2 S{"Y=" ^ var.probePosAveraged}

; Absolute moves to find ending position
G90

; Move to safe height
G53 G0 Z{param.S}

set global.touchProbeCoordinateY=var.probePosAveraged + var.probeRadiusComp