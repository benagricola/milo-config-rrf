; Park spindle, move work area to an easily accessible spot for the operator.
M5                                     ; make sure spindle is stopped or powering down
G90                                    ; absolute positioning
G21                                    ; use MM
G53 G0 Z{global.parkZ}                 ; Lift Z to parking location
G53 G0 X{global.parkX} Y{global.parkY} ; Move work area to accessible location