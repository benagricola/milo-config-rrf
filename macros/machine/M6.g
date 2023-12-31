; Called when the tool needs changing.

; RRF's toolchange macros have to be pre-defined per-tool.
; This is a pain because it means we need to account for all tool
; numbers - but we do the same thing for every tool anyway, which
; is - stop the spindle, park it, and prompt the user to change
; the tool manually before proceeding.

; RRF does allow you to use 'dynamic' (i.e. non-predefined)
; tool numbers, but these won't actually change the _currently_
; selected tool because they don't exist. But if you run
; T<non-existent> then the non-existent tool number is stored in
; state.nextTool even though state.currentTool is not modified.
; We can exploit this behaviour to allow standard code like
; T5 M6 to prompt a tool change, picking the tool number from
; the next tool number.

; NOTE: This can be called in a nonstandard manner, by specifying
; the S parameter. S can be used to specify the _name_ of the tool
; to change to, which is more appropriate as full tool tables are
; not needed by RRF.

G27      ; park spindle away from work piece to allow more room
         ; for changing tool.


; If nextTool is -1, it probably means the user tried to change to
; tool 1, which is automatically processed by RRF and clears nextTool
; automatically.
; Record tool before deactivating spindle
var toolIndex = state.nextTool == -1 ? 1 : state.nextTool

M98 P"macros/tool/tool-deactivate.g" ; Deactivate the spindle

var toolDescription = global.toolTable[var.toolIndex-1]

; Prompt user to change tool
M291 R"Change Tool" P{"Insert Tool #" ^ var.toolIndex ^ ": " ^ var.toolDescription ^ ". OK when ready." } S3

M118 P0 L2 S{"Active Tool #" ^ var.toolIndex}

; Probe tool offset
; Pass tool index to G37 so it does not use its'
; internal tool selection process
; Run G37 "unsafely" as we control tool activation in
; M6 instead.
G37 I{var.toolIndex} U1

; Continue after user confirmation if necessary
if { global.confirmToolChange }
    M291 R"Tool Ready?" P"CAUTION: Tool change complete. Ready to continue? Spindle will be re-activated when you click OK!" S3
    if result == 0
        M98 P"macros/tool/tool-activate.g" ; Reactivate the spindle
else
    M98 P"macros/tool/tool-activate.g" ; Reactivate the spindle

var toolOffset = global.toolZTable[var.toolIndex-1]

M118 P0 L2 S{"Setting tool offset to " ^ var.toolOffset ^ "mm"}

; Set the current tool offset using the probed offset from the tool number
G10 P{global.spindleID} X0 Y0 Z{var.toolOffset}
