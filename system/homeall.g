; homeall.g
; Homes Z, then homes X and Y together using user-defined limits

G91                                                  ; relative positioning
G53 G0 H1 Z{global.zHome}                            ; Move towards endstop
G53 G0 H2 Z{global.zHomeRepeat}                      ; Back off a little
G53 G1 H1 Z{global.zHome} F{global.zHomeRepeatSpeed} ; Home slowly now we know where it is

; Move quickly to X and Y axis endstops and stop there (first pass)
G53 G0 H1 X{global.xHome} Y{global.yHome}

; Go back ready to repeat
G53 G0 H2 X{global.xHomeRepeat} Y{global.yHomeRepeat}

; Second-pass homing, should be more accurate
G53 G1 H1 X{global.xHome} Y{global.yHome} F{global.xyHomeRepeatSpeed}

G90        ; absolute positioning
G53 G92 Z0 ; set Z position to axis maximum (0)
