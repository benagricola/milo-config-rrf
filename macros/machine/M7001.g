; M7001.g
; Disable Variable Spindle Speed Control
;
; USAGE: "M7001"

; Disable the daemon process
set global.vsscEnabled  = false

; If spindle is active, adjust speed to last recorded
; 'base' RPM
if { spindles[global.spindleID].state == "foward" }
    ; Set spindle RPM
    M568 P0 F{ global.vsscPreviousAdjustmentRPM }

    if { global.vsscDebug }
        M118 P0 L2 S{"[VSSC]: State: Disabled RPM: " ^ global.vsscPreviousAdjustmentRPM }
else
    if { global.vsscDebug }
        M118 P0 L2 S{"[VSSC]: State: Disabled" }

; Update adjustment time, RPM and direction
set global.vsscPreviousAdjustmentTime = 0
set global.vsscPreviousAdjustmentRPM  = 0
set global.vsscPreviousAdjustmentDir  = true