; M7002.g
; Prompt operator to plug in touch probe before continuing!
;
; USAGE: "M7002"

; Check if touchprobe feature is available
if { !exists(global.featureTouchProbe) || !global.featureTouchProbe }
    abort "M7002: Cannot use touch probe, feature disabled!"

; Start probing sequence
if { !exists(global.touchProbeConnected) || global.touchProbeConnected == false }
    M98 P"tool-deactivate.g"
    M291 P"Install touch probe in spindle and confirm it is plugged in!" R"Installation check" S3
    if result == 0
        set global.touchProbeConnected = true
    else
        abort { "M7002: Touch probe not installed! Aborting." }