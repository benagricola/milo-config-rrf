; G6010: Repeatable edge (horizontal) probe, X axis

; Assume probe is clear to move in X/Y to starting position,
; then plunge to Z starting position.

; Switch to mm
G21

var retries           = 0
var probePos          = 0
var curPos            = 0
var backoffPos        = global.touchProbeRepeatXY
var probeCompensation = { - (global.touchProbeRadius - global.touchProbeDeflection) }

if { !exists(param.D) || param.D == 0 }
    abort { "Must provide direction and distance (D+-..) you want to probe in!" }

if { !exists(param.X) || !exists(param.Y) || !exists(param.Z) }
    abort { "Must provide starting position (X.., Y.., Z..)!" }

if param.D == param.X
    abort { "Parameters X and D cannot be the same!" }

if { !exists(param.S) }
    abort { "Must provide a safe height (S..) to retreat to after probing for subsequent moves!" }

if { param.S < param.Z }
    abort { "Safe height (S..) must be greater than starting height (Z..)!" }

; Confirm touch probe available and connected
M7002

if { global.confirmUnsafeMove }
    M291 P{"Move to X=" ^ param.X ^ ", Y=" ^ param.Y ^ " at safe Z=" ^ param.S ^ ", down towards Z=" ^ param.Z ^ " and probe X=" ^ param.D ^ "?"} R"Safety check" S3

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
if { param.X < param.D }
    set var.backoffPos      = -var.backoffPos
    set var.probeCompensation = { abs(var.probeCompensation) }

while var.retries <= global.touchProbeNumProbes
    ; Probe towards surface
    G53 G38.2 X{param.D} K{global.touchProbeID}

    ; Abort if an error was encountered 
    if { result != 0 }
        ; Reset all speed limits after probe
        M98 P"system/speed.g"
        abort { "Probe experienced an error, aborting!" }

    ; Record current position
    set var.curPos = move.axes[0].machinePosition

    ; Increase Z speed for backing off
    ; Reduce acceleration
    M203 X{global.touchProbeRoughSpeed}
    M201 X{global.maxAccelLimitX/2}

    ; Move away from the trigger point
    G53 G0 X{var.backoffPos}

    ; If this is not the initial rough probe, record the position
    if var.retries > 0
        ; Add probe position for averaging
        set var.probePos = var.probePos+var.curPos

        M118 P0 L2 S{"Touch Probe " ^ var.retries ^ "/" ^ global.touchProbeNumProbes ^ ": X=" ^ var.curPos}

    ; Dwell so machine can settle
    G4 P{global.touchProbeDwellTime}

    ; Drop speed in probe direction for next probe attempt
    M203 X{global.probeSpeed}

    ; Iterate retry counter
    set var.retries = var.retries + 1

; Make sure to reset all speed limits after probing complete
M98 P"system/speed.g"

var probePosAveraged = var.probePos / global.touchProbeNumProbes

M118 P0 L2 S{"X=" ^ var.probePosAveraged}

; Absolute moves to find ending position
G90

; Move to safe height
G53 G0 Z{param.S}

set global.probeCoordinateX=var.probePosAveraged + var.probeCompensation