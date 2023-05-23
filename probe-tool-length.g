; Probe the current tool length and save its' offset.
; Offset is in relation to the spindle nose.

; Vars
var startHeight = global.toolsetterSpindleNoseOffset + global.toolsetterMaxLength

; Reset tool offset
G10 P1 Z0

; Move spindle away from the work piece carefully
M913 Z25  ; Reduce Z motor current before probing in case something goes wrong
G90       ; absolute positioning
G1 Z0     ; lift Z to 0 to avoid crashing during moves


G1 X{global.toolsetterX} Y{global.toolsetterY} Z{startHeight} F3000 ; Move the tool above the touch probe
M585 Z-{global.toolsetterMaxLength} F600 P1 S1                      ; Probe tool length

M913 Z100  ; Increase motor current after homing

G91        ; Relative positioning
