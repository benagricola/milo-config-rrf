; homeall.g
; Homes Z, then homes X and Y together using user-defined limits

G91                                              ; relative positioning
G0 H1 Z{global.zHome}                            ; Move towards endstop  
G0 H2 Z{global.zHomeRepeat}                      ; Back off a little 
G1 H1 Z{global.zHome} F{global.zHomeRepeatSpeed} ; Home slowly now we know where it is

G0 H1 X{global.xHome} Y{global.yHome}                             ; move quickly to X and Y axis endstops and stop there (first pass)
G0 H2 X{global.xHomeRepeat} Y{global.yHomeRepeat}                 ; go back a few mm
G1 H1 X{global.xHome} Y{global.yHome} F{global.xyHomeRepeatSpeed} ; move slowly to X and Y axis endstops once more (second pass)

G90    ; absolute positioning
G92 Z0 ; set Z position to axis maximum (0)
