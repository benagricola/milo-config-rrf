; homex.g
; Home X axis

G0 Z0 ; lift Z

G91   ; relative positioning

G0 H1 X{global.xHome}                             ; move quickly to X axis endstop and stop there (first pass)
G0 H2 X{global.xHomeRepeat}                       ; go back a few mm
G1 H1 X{global.xHome} F{global.xyHomeRepeatSpeed} ; move slowly to X axis endstop once more (second pass)

G90 ; absolute positioning
