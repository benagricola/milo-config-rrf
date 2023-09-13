; G6999.g
; Prompt operator to plug in touch probe before continuing!
;
; USAGE: "G6999"

; Check if touchprobe feature is available
if { !exists(global.featureTouchProbe) || !global.featureTouchProbe }
    abort "G6999: Cannot use touch probe, feature disabled!"

; Start probing sequence
if { !global.touchProbeConnected }
    M291 P"Install touch probe in spindle and confirm it is plugged in!" R"Installation check" S3
    ; Deselect all tools (TODO: Check if this disables spindle)
    T-1
    set global.touchProbeConnected = true