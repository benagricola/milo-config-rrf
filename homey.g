G1 Z0 F6000       ; lift Z

G91                 ; relative positioning

G1 H1 Y{global.yHome} F1800       ; move quickly to Y axis endstops and stop there (first pass)
G1 H2 Y{global.yHomeRepeat} F6000 ; go back a few mm
G1 H1 Y{global.yHome} F360        ; move slowly to Y axis endstops once more (second pass)

G90                 ; absolute positioning
