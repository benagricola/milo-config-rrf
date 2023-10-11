; G27.g
; Park spindle, move work area to an easily accessible spot for the operator.
;
; USAGE: "G27" or "G27 C1"

; Stop spindle after raising Z, in case it is spinning and
; in contact with the work piece when this macro is called.

G90                    ; absolute positioning
G21                    ; use MM
G53 G0 Z{global.parkZ} ; lift Z to parking location

M5                     ; make sure spindle is stopped or powering down

; If requesting centre, move to middle of X and Y
if { exists(param.C) }
    G53 G0 X{(global.xMax - global.xMin)/2} Y{(global.yMax - global.yMin)/2}
else
    ; Otherwise move to operator-specified accessible location
    G53 G0 X{global.parkX} Y{global.parkY}