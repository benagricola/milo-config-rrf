G91                               ; relative positioning
G1 H1 Z{global.zHome) F1800       ; Move towards endstop  
G1 H2 Z{global.zHomeRepeat} F6000 ; Back off a little 
G1 H1 Z{global.zHome) F360        ; Home slowly now we know where it is

G1 H1 X{global.xHome} Y{global.yHome} F1800              ; move quickly to X and Y axis endstops and stop there (first pass)
G1 H2 X{global.xHomeRepeat} Y{global.yHomeRepeat} F6000  ; go back a few mm
G1 H1 X{global.xHome} Y{global.yHome} F360               ; move slowly to X and Y axis endstops once more (second pass)

G90                     ; absolute positioning
G92 Z0                  ; set Z position to axis maximum (0)
