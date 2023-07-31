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

G27      ; park spindle away from work piece

; If nextTool is -1, it probably means the user tried to change to
; tool 1, which is automatically processed by RRF and clears nextTool
; automatically.
var toolIndex = state.nextTool == -1 ? 1 : state.nextTool

; Prompt user to change tool
if { exists(param.S) }
    M291 R"Change Tool" P{"Insert Tool #" ^ var.toolIndex ^ ": " ^ param.S ^ ". OK when ready." } S3
else
    M291 R"Change Tool" P{"Insert Tool #" ^ var.toolIndex ^ ". OK when ready." } S3

M118 P0 L2 S{"Active Tool #" ^ var.toolIndex}

; At this point the tool has technically been changed,
; but because it may be a dynamic tool, we'll just set
; the spindle active.

T1 P0 ; Do not run any tool change macros.

; Probe tool offset
G37

; Continue