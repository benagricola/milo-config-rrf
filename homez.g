G91               ; relative positioning

G1 H1 Z{global.zHome} F1800       ; Move towards endstop  
G1 H2 Z{global.zHomeRepeat} F6000 ; Back off a little 
G1 H1 Z{global.zHome} F360        ; Home slowly now we know where it is

G92 Z0                       ; set Z position to axis minimum (you may want to adjust this)
G90                          ; absolute positioning
