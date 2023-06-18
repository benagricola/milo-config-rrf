; Safely move to WCS Zero with user confirmation

; Park approximately central
G27 C1

G90                             ; Absolute positioning
G21                             ; use MM

G0 X0 Y0                        ; Move laterally to WCS Zero
G0 Z{global.workZeroSafeHeight} ; Plunge to just above Zero

M291 P{"Current position Z=" ^ global.workZeroSafeHeight ^ " - Move to Z=0?"} R"Safety check" S3

G0 Z0; go to the work Z zero position 