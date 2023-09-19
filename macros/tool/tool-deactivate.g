
; tool-deactivate.g
; Deletes a tool based on pre-defined spindle pins

; We deactivate (delete) the tool during dangerous operations
; like tool changes and touch probing, to avoid firing up the spindle
; when the user may be near to it.

M563 P{global.spindleID} R-1    ; Remove spindle
M950 R{global.spindleID} C"nil" ; Remove spindle pin
M118 P0 L2 S{"Spindle " ^ global.spindleID ^ " deactivated"}