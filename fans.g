; Fans

; Configure fan port 0 (120mm main fan)
M950 F0 C"!fan0+tacho0" Q500
M106 P0 S1 H-1

; Disable fan port 1, used for spindle enable
M950 F1 C"nil"

