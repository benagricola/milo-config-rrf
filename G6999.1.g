; G6999.1.g
; Prompt operator to remove touch probe before continuing!
;
; USAGE: "G6999.1"

; Check if touchprobe feature is available
if { !exists(global.featureTouchProbe) || !global.featureTouchProbe }
    abort "G6999.1: Cannot use touch probe, feature disabled!"

; Do not check if touch probe is connected. It's safer to just prompt.
M291 P{"Unplug and remove your touch probe before proceeding!"} R"Safety Check" S3
set global.touchProbeConnected = false

; Select default tool
T{global.spindleID}