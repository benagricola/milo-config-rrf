G90                                        ; absolute positioning
G21                                        ; use MM
G53 G0 Z{global.zMax}                      ; Lift Z to max
M5                                         ; Turn off the spindle
G4 S15                                     ; Wait for the spindle to stop
G53 G0 X{global.xMax / 2} Y{global.yMax}   ; Move work to front
