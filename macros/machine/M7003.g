; M7003.g
; Prompt operator to remove touch probe before continuing!
;
; USAGE: "M7003"

; Check if touchprobe feature is available
if { !global.featureTouchProbe }
    ; Just activate tool if no touch probe available
    M98 P"macros/tool/tool-activate.g"
else
    ; Otherwise only activate tool after user confirms touch probe is stowed.
    if { global.touchProbeConnected == true }
        M291 P{"Unplug, remove your touch probe and stow the cable securely before proceeding!"} R"Safety Check" S3
        if result == 0
            set global.touchProbeConnected = false
            M98 P"macros/tool/tool-activate.g"