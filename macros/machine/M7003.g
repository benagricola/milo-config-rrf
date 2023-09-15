; M7003.g
; Prompt operator to remove touch probe before continuing!
;
; USAGE: "M7003"

; Check if touchprobe feature is available
if { !exists(global.featureTouchProbe) || !global.featureTouchProbe }
    abort "M7003: Cannot use touch probe, feature disabled!"

; Do not check if touch probe is connected. It's safer to just prompt.
if { global.touchProbeConnected == true }
    M291 P{"Unplug, remove your touch probe and stow the cable securely before proceeding!"} R"Safety Check" S3
    if result == 0
        set global.touchProbeConnected = false
        M98 P"macros/tool/tool-activate.g"