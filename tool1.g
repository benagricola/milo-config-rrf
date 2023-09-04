; tool1.g
; Configures attached spindle

M950 R1 C{global.pinTool} L{global.spindleMaxRPM}  Q{global.spindlePWMFrequency} 

M563 P1 S"Spindle 1" R1                ; Assign spindle index 1 name

G10 P1 X0 Y0 Z0                        ; Set tool axis offsets

