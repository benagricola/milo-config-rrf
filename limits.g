; Configure machine limits

; Axis Limits
M208 X{global.xMin} Y{global.yMin} Z{global.zMin} S1                  ; set axis minima
M208 X{global.xMax} Y{global.yMax} Z{global.zMax} S0                  ; set axis maxima

; Endstops
; X=0: NC, pulled up, on xstop 
M574 X1 S1 P"^xstop"

; Y=0: NC, pulled up, on ystop 
M574 Y1 S1 P"^ystop"

; Z=120: NC, pulled up, on xstop 
M574 Z2 S1 P"^zstop"

; Z-Probe (does not exist, manual setup)
M558 K0 P0                           ; disable Z probe

