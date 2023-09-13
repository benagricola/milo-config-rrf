; homey.g
; Home Y axis

G0 Z0 ; lift Z

G91   ; relative positioning

G0 H1 Y{global.yHome}                             ; move quickly to Y axis endstop and stop there (first pass)
G0 H2 Y{global.yHomeRepeat}                       ; go back a few mm
G1 H1 Y{global.yHome} F{global.xyHomeRepeatSpeed} ; move slowly to Y axis endstop once more (second pass)

G90 ; absolute positioning
