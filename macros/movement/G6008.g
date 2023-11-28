; G6008: Manual edge (horizontal) probe, Y axis

; Assume tool is clear to move in X/Y to starting position,
; then plunge to Z starting position.

; Switch to mm
G21

if { !exists(param.D) || param.D == 0 }
    abort { "Must provide direction and distance (D+-..) you want to probe in!" }

if { !exists(param.X) || !exists(param.Y) || !exists(param.Z) }
    abort { "Must provide starting position (X.., Y.., Z..)!" }

if { !exists(param.R) || param.R == 0 }
    abort { "Must provide tool radius to compensate for!" }

if param.D == param.Y
    abort { "Parameters Y and D cannot be the same!" }

if { !exists(param.S) }
    abort { "Must provide a safe height (S..) to retreat to after probing for subsequent moves!" }

if { param.S < param.Z }
    abort { "Safe height (S..) must be greater than starting height (Z..)!" }

var toolCompensation = { -(param.R) }

if { global.confirmUnsafeMove }
    M291 P{"Move to X=" ^ param.X ^ ", Y=" ^ param.Y ^ " at safe Z=" ^ param.S ^ ", down towards Z=" ^ param.Z ^ " and jog towards Y=" ^ param.D ^ "?"} R"Safety check" S3

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

; If moving in a positive direction, compensate for tool radius
; in positive (when tool touches surface, it is at an X
; co-ordinate LESS than where the actual surface is, by the
; radius of the tool).
if { param.Y < param.D }
    set var.toolCompensation = { abs(var.toolCompensation) }

; Drop speed in probe direction
M203 Y{global.probeSpeed}

M291 P{"Jog the tool towards the surface until you can feel slight resistance when turning the tool backwards (by hand!) and press OK"} R"Jog to surface" S3 Y1

if { result != 0 }
    abort "Operator aborted manual probing operation!"

var probePos = move.axes[1].machinePosition

; Make sure to reset all speed limits after probing complete
M98 P"speed.g"

M118 P0 L2 S{"Y=" ^ var.probePos}

; Absolute moves to find ending position
G90

; Move to safe height
G53 G0 Z{param.S}

set global.probeCoordinateY=var.probePos + var.toolCompensation