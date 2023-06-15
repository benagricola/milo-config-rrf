; G6002: Repeatable edge (horizontal) probe, Y axis

; Assume probe is clear to move in X/Y to starting position,
; then plunge to Z starting position.

; Switch to mm
G21

var retries       = 1
var probePos      = 0
var curPos        = 0
var backoffPos    = global.touchProbeDistanceXY

if { !exists(param.D) || param.D == 0 }
    { abort "Must provide direction and distance (D=+-...) you want to probe in!" }

if { !exists(param.X) || !exists(param.Y) || !exists(param.Z) }
    { abort "Must provide starting position (X=, Y=, Z=)!" }

if { !exists(param.S) }
    { abort "Must provide a safe height (S=) to retreat to after probing for subsequent moves!" }

M291 P{ "Probe will move to absolute position X=" ^ param.X ^ ", Y=" ^ param.Y ^ " at a safe height of Z=" ^ param.S ^ ", then down to Z=" ^ param.Z ^ ", and will probe towards Y=" ^ param.D ^ ". Confirm?" } R"Safety check" S2

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
if { param.D > 0 }
    set var.backoffPos = -var.backoffPos

while var.retries <= global.touchProbeNumProbes
    ; Probe towards surface
    G53 G38.2 Y{param.D} K2
    
    set var.curPos = move.axes[1].machinePosition

    ; Add probe position for averaging
    set var.probePos = var.probePos+var.curPos

    M118 P0 L2 S{"Touch Probe " ^ var.retries ^ "/" ^ global.touchProbeNumProbes ^ ": Y=" ^ var.curPos}

    ; Move away from the trigger point
    G53 G0 Y{var.backoffPos}

    ; Iterate retry counter
    set var.retries = var.retries + 1

var probePosAveraged = var.probePos / global.touchProbeNumProbes

M118 P0 L2 S{"Y=" ^ var.probePosAveraged}

; Absolute moves to find ending position
G90

; Move to safe height
G53 G0 Z{param.S}

set global.touchProbeCoordinateY=var.probePosAveraged