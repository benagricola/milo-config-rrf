; homex.g
; Home X axis

G53 G0 Z{global.zMax} ; lift Z

G91   ; relative positioning

; Move quickly to X axis endstop and stop there (first pass)
G53 G0 H1 X{global.xHome}

; Go back ready to repeat
G53 G0 H2 X{global.xHomeRepeat}

; Second-pass homing, should be more accurate
G53 G1 H1 X{global.xHome} F{global.xyHomeRepeatSpeed}

G90 ; absolute positioning
