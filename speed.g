; Configure maximum speeds and jerk (instantaneous speed changes)

; This is a CNC, we don't want to jerk really
M566 X60.00 Y60.00 Z10.00                                                      ; Set maximum instantaneous speed changes (mm/min)
M203 X{global.maxSpeedLimitX} Y{global.maxSpeedLimitY} Z{global.maxSpeedLimitZ} ; Set maximum speeds (mm/min)
M201 X1000.00 Y1000.00 Z20.00                                                  ; Set accelerations (mm/s^2)

