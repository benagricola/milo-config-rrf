; Configure machine limits

; Axis Limits
M208 X{global.xMin} Y{global.yMin} Z{global.zMin} S1                  ; set axis minima
M208 X{global.xMax} Y{global.yMax} Z{global.zMax} S0                  ; set axis maxima

; Endstops
; The spindle is stationary, so we're looking for 0,0
; to be when the bottom left of the work area is under
; the spindle. X homes to the _right_ (towards the
; spindle) so endstop position is 0, Y homes towards
; the operator (away from the spindle) so endstop
; position is MAX.
; Z homes upwards to zero.

; X=0: NC, pulled up, on xstop 
M574 X1 S1 P{global.pinXStop}

; Y=MAX: NC, pulled up, on ystop
M574 Y2 S1 P{global.pinYStop}

; Z=MAX: NC, pulled up, on xstop
M574 Z2 S1 P{global.pinZStop}

; Default Z-Probe (does not exist, manual setup)
M558 K0 P0 ; disable Z probe

