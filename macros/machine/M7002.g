; M7002.g
; Prompt operator to plug in touch probe before continuing!
; If touch probe feature is not available, warn user about
; manual probing methods.
;
; Disable the tool before performing any probing.
; Manual probing involves turning the spindle by hand
; backwards so it is _very_ important that the tool is
; deactivated at this point.
;
; USAGE: "M7002"

; Check if touchprobe feature is available
if { !global.featureTouchProbe }
    ; Give the user a manual-probing safety prompt if not
    M291 P{"You are about to probe a work piece by jogging the current tool (GENTLY!) against the relevant surfaces. Make sure your jog distances are set appropriately before continuing!"} R"Safety Check" S3
    ; And deactivate the tool
    M98 P"macros/tool/tool-deactivate.g"
else
    ; Start probing sequence
    if { !exists(global.touchProbeConnected) || global.touchProbeConnected == false }
        M98 P"macros/tool/tool-deactivate.g"
        M291 P"Install touch probe in spindle and confirm it is plugged in!" R"Installation check" S3
        if result == 0
            set global.touchProbeConnected = true
        else
            abort { "M7002: Touch probe not installed! Aborting." }