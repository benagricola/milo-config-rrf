; Perform a repeatable, averaged probe of a surface and
; return the Z height when finished.

set global.touchProbeCoordinate=0

; Switch to mm / relative positions for repeated probing.
; Assume probe is already in the correct starting position.
G21
G91

; Probe until we touch the surface
var retries     = 1
var probeOffset = 0

while var.retries <= global.touchProbeNumProbes
    ; Probe towards surface
    G53 G30 K2 S-1

    var curOffset = move.axes[2].machinePosition

    ; Add probe offset for averaging
    set var.probeOffset = var.probeOffset + curOffset

    M118 P0 L2 S{"Touch Probe " ^ var.retries ^ "/" ^ global.touchProbeNumProbes ^ ": " ^ var.curOffset}

    ; Move away from the trigger point
    G53 G0 Z{global.touchProbeDistanceZ}

    ; Iterate retry counter
    set var.retries = var.retries + 1

M118 P0 L2 S{"Z=" ^ var.probeOffset}

set global.touchProbeCoordinate=var.probeOffset