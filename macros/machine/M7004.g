; M7004.g
; Warn operator of manual probing methodology
;
; USAGE: "M7004"

M291 P{"You are about to probe a work piece by jogging the current tool (GENTLY!) against the relevant surfaces. Make sure your jog distances are set appropriately before continuing!"} R"Safety Check" S3
M98 P"macros/tool/tool-deactivate.g"
