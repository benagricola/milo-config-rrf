; homez.g
; Home Z axis

G91                                                  ; relative positioning
G53 G0 H1 Z{global.zHome}                            ; Move towards endstop
G53 G0 H2 Z{global.zHomeRepeat}                      ; Back off a little
G53 G1 H1 Z{global.zHome} F{global.zHomeRepeatSpeed} ; Home slowly now we know where it is

G90        ; absolute positioning
G53 G92 Z0 ; set Z position to axis maximum (0)
