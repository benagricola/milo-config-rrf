; Park spindle, move work area to an easily accessible spot for the operator.
M5                                     ; make sure spindle is stopped or powering down
G90                                    ; absolute positioning
G21                                    ; use MM
G53 G0 Z{global.parkZ}                 ; Lift Z to parking location
; If requesting centre, move to middle of X and Y
if { exists(param.C) }
    G53 G0 X{(global.xMax - global.xMin)/2} Y{(global.yMax - global.yMin)/2}
else
    ; Otherwise move to operator-specified accessible location
    G53 G0 X{global.parkX} Y{global.parkY}