; G6013.g
; G6013: Probe reference surface

; Uses the safe Z probe macro G6012 to probe a user-defined
; reference surface. This surface is used to calculate tool
; offsets when using a toolsetter to probe tool length.

; If reference surface is already probed we will _not_
; probe it again by default. This is to avoid probe
; repeatability issues from affecting existing tool offsets.

; Check if toolsetter feature is available
; No need to probe reference surface if we don't have a toolsetter
if { !exists(global.featureToolSetter) || !global.featureToolSetter }
    abort "No need to probe reference surface with toolsetter feature disabled!"

    
if { global.referenceSurfaceZ == 0 || exists(param.R) } 
    ; Confirm touch probe available and connected
    M7002

    M118 P0 L2 S{"Probing ref. surface at X=" ^ global.touchProbeReferenceX ^ ", Y=" ^ global.touchProbeReferenceY }

    G6012 X{global.touchProbeReferenceX} Y{global.touchProbeReferenceY} S{global.zMax} B{global.touchProbeRepeatZ} K{global.touchProbeID} C{global.touchProbeNumProbes} V{global.probeSpeed}

    ; Set our reference surface height for storage
    set global.referenceSurfaceZ = global.probeCoordinateZ

M118 P0 L2 S{"Reference Surface Z=" ^ global.referenceSurfaceZ}