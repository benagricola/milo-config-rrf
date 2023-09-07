; Configure maximum speeds and jerk (instantaneous speed changes)

; This is a CNC, we don't want to jerk really
M566 X{global.maxJerkLimitX} Y{global.maxJerkLimitY} Z{global.maxJerkLimitZ}    ; Set maximum instantaneous speed changes (mm/min)
M203 X{global.maxSpeedLimitX} Y{global.maxSpeedLimitY} Z{global.maxSpeedLimitZ} ; Set maximum speeds (mm/min)
M201 X{global.maxAccelLimitX} Y{global.maxAccelLimitY} Z{global.maxAccelLimitZ} ; Set accelerations (mm/s^2)

