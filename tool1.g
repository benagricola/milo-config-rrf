; Tools
M950 R1 C"he0+^fan1" L24000  Q40      ; Create spindle index 1, with PWM on he0, enable pin on fan1 (12v configured fan) and 24kRPM achieved at full PWM
M563 P1 S"Spindle 1" R1               ; Assign spindle index 1 name

G10 P1 X0 Y0 Z0                       ; Set tool axis offsets
T1                                    ; Select tool
