G90                                        ; absolute positioning
G21                                        ; use MM
G1 Z{global.zMax} F360                     ; Lift Z to max
M5                                         ; Turn off the spindle
G4 S15                                     ; Wait for the spindle to stop
G1 X{global.xMax / 2} Y{global.yMax} F6000 ; Move work to front
