G1 Z0 F6000       ; lift Z

G91                 ; relative positioning

G1 H1 X{global.xHome} F1800       ; move quickly to X axis endstops and stop there (first pass)
G1 H2 X{global.xHomeRepeat} F6000 ; go back a few mm
G1 H1 X{global.xHome} F360        ; move slowly to X axis endstops once more (second pass)

G90                 ; absolute positioning
