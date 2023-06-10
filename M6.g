; Called when the tool needs changing.

M5        ; Stop spindle
G53 G0 Z0 ; Move spindle away from workpiece while decelerating

; Prompt user to change tool

; Probe tool offset
G37

; Move tool over 0,0 and allow user to confirm

; Continue