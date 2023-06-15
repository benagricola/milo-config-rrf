; G6003: Repeatable surface (vertical) probe, Z axis

; Z Probing will move to the safe height (S) _before_ moving
; horizontally.

; IF IN DOUBT: Make sure the tool is fully retracted upwards before
; running this macro to lessen the chances of running the probe
; into anything on the work surface.

; Switch to mm / relative positions for repeated probing.
G21
G91

var retries       = 1
var probePos      = 0
var curPos        = 0

if { !exists(param.X) || !exists(param.Y) }
    { abort "Must provide starting position (X=, Y=)!" }

if { !exists(param.S) }
    { abort "Must provide a safe height (S=) to retreat to after probing for subsequent moves!" }

if global.touchProbeConfirmMove
    M291 P{"Move to X=" ^ param.X ^ ", Y=" ^ param.Y ^ " at safe Z=" ^ param.S ^ ", probe towards Z=" ^ global.zMin ^ "?"} R"Safety check" S2

; Absolute moves to find starting position
G90

; Move to safe height
G53 G0 Z{param.S}

; Move to starting position
G53 G0 X{param.X} Y{param.Y}

; Back to relative moves for probing
G91

while var.retries <= global.touchProbeNumProbes
    ; Probe towards surface.
    ; Z probes only run in one direction
    G53 G38.2 K2 Z{global.zMin}
    
    set var.curPos = move.axes[2].machinePosition

    ; Add probe position for averaging
    set var.probePos = var.probePos+var.curPos

    M118 P0 L2 S{"Touch Probe " ^ var.retries ^ "/" ^ global.touchProbeNumProbes ^ ": Z=" ^ var.curPos}

    ; Move away from the trigger point
    G53 G0 Z{global.touchProbeDistanceZ}

    ; Iterate retry counter
    set var.retries = var.retries + 1

var probePosAveraged = var.probePos / global.touchProbeNumProbes

M118 P0 L2 S{"Z=" ^ var.probePosAveraged}

; Absolute moves to find ending position
G90

; Move to safe height
G53 G0 Z{param.S}

set global.touchProbeCoordinateZ=var.probePosAveraged