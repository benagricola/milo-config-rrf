; homey.g
; Home Y axis

G53 G0 Z{global.zMax} ; lift Z

G91   ; relative positioning

; Move quickly to Y axis endstop and stop there (first pass)
G53 G0 H1 Y{global.yHome}

; Go back ready to repeat
G53 G0 H2 Y{global.yHomeRepeat}

; Second-pass homing, should be more accurate
G53 G1 H1 Y{global.yHome} F{global.xyHomeRepeatSpeed}

G90 ; absolute positioning
