; G6009: Manual surface (vertical) probe, Z axis

; Assume tool is clear to move in X/Y to starting position,
; then plunge to Z starting position.

; Switch to mm
G21

; These positions are absolute and negated at the end
; of the macro, to make reasoning about the logic
; simpler.
var probePos      = 0
var probePosMin   = { abs(global.zMin) }
var probePosMax   = 0

if { !exists(param.X) || !exists(param.Y) }
    abort { "Must provide starting position (X.., Y..)!"  }

if { !exists(param.S) }
    abort { "Must provide a safe height (S..) to retreat to after probing for subsequent moves!"  }

if { !exists(param.V) }
    abort { "Must provide a vertical (V..) probe speed!"  }

if { global.confirmUnsafeMove }
    M291 P{"Move to X=" ^ param.X ^ ", Y=" ^ param.Y ^ " at safe Z=" ^ param.S ^ ", and jog towards Z=" ^ global.zMin ^ "?"} R"Safety check" S3

; Absolute moves to find starting position
G90

; Move to safe height
G53 G0 Z{param.S}

; Move to starting position
G53 G0 X{param.X} Y{param.Y}

; Back to relative moves for probing
G91

M201 Z{global.maxAccelLimitZ/2}
M203 Z{param.V}

M291 P{"Jog the tool downwards until you can feel slight resistance against the top surface when turning the tool backwards (by hand!) and press OK"} R"Jog to surface" S3 Z1

if { result != 0 }
    M98 P"system/speed.g"
    abort "Operator aborted manual probing operation!"

set var.probePos = { abs(move.axes[2].machinePosition) }

; Make sure to reset all speed limits after probing complete
M98 P"system/speed.g"

M118 P0 L2 S{"Z=" ^ var.probePos}

; Absolute moves to find ending position
G90

; Move to safe height
G53 G0 Z{param.S}

set global.probeCoordinateZ=var.probePos