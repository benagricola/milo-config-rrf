; M7001.g
; Disable Harmonic Spindle Speed Control
;
; USAGE: "M7001"

; Disable the daemon process
set global.hsscEnabled  = false

; If spindle is active, adjust speed to last recorded
; 'base' RPM
if { spindles[global.spindleID].state == "foward" }
    ; Set spindle RPM
    M568 P0 F{ global.hsscPreviousAdjustmentRPM }

    if { global.hsscDebug }
        M118 P0 L2 S{"[HSSC]: State: Disabled RPM: " ^ global.hsscPreviousAdjustmentRPM }
else
    if { global.hsscDebug }
        M118 P0 L2 S{"[HSSC]: State: Disabled" }

; Update adjustment time, RPM and direction
set global.hsscPreviousAdjustmentTime = 0
set global.hsscPreviousAdjustmentRPM  = 0
set global.hsscPreviousAdjustmentDir  = true