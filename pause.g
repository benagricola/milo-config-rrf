G90                                    ; absolute positioning
G21                                    ; use MM
G1 Z{global.zMax} F360                 ; Lift Z to max
M5                                     ; Turn off the spindle
G4 S15                                 ; Wait for the spindle to stop
G1 X{global.xMin} Y{global.yMin} F6000 ; Go to X,Y min
