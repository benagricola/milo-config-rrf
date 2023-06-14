; G6003: Repeatable surface probe, Z axis

; Assume probe is PARKED, since
; user needs to jog it over the surface anyway.

; Switch to mm / relative positions for repeated probing.
G21
G91

var retries       = 1
var probePos      = 0
var curPos        = 0

if !exists(param.X) || !exists(param.Y)
    abort "Must provide starting position (X=, Y=)!"

if !exists(param.S)
    abort "Must provide a safe height (S=) to retreat to after probing for subsequent moves!"

M291 P"Probe will move to absolute position X=" ^ param.X ^ ", Y=" ^ param.Y ^ " at a safe height of Z=" ^ param.S ^ ", then will probe towards Z=" ^ global.minZ ^ ". Confirm?" R"Safety check" S2

; Absolute moves to find starting position
G90

; Move to safe height
G53 G0 Z{param.S}

; Move to starting position
G53 G0 X{param.X} Y{param.Y}

while var.retries <= global.touchProbeNumProbes
    ; Probe towards surface.
    ; Z probes only run in one direction
    G53 G38.2 K2
    
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