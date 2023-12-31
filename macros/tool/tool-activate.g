
; tool-activate.g
; Creates tool based on pre-defined spindle pins

; By separating activation out into a separate file, we can also
; deactivate the tool during dangerous operations like tool changes
; and touch probing. By deactivating the tool, we hopefully avoid
; the possibility of accidentally spinning up the tool due to a bug
; in this code, or in how RRF does (or does not) process aborts
; or exits during the machining process.

;M950 R{global.spindleID} C{global.pinTool} L{global.spindleMinRPM}:{global.spindleMaxRPM Q{global.spindlePWMFrequency}
M950 R{global.spindleID} C{global.pinTool} L{global.spindleMaxRPM} Q{global.spindlePWMFrequency}
M563 P{global.spindleID} R{global.spindleID} S"Spindle"   ; Assign spindle index 1 name

T{global.spindleID} ; Select tool

; Note: At this point, the tool has _NO_ offset configured.
; It is up to the calling macro to set the correct tool offset (usually M6)

M118 P0 L2 S{"Spindle " ^ global.spindleID ^ " activated"}