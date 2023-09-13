; M4000.g
; Defines a tool by index and description

; In combination with T<N> M6, we can prompt users to change using
; a user-friendly process.

; Prompt user to change tool
if { !exists(param.I) || !exists(param.D) }
    abort "Must provide tool number (I...) and description (D\"..."\) to register tool!"

var toolID = param.I
var toolDesc = param.D
if { var.toolID > #global.toolTable }
    abort { "Tool index must be less than or equal to " ^  #global.toolTable ^ "!" }

; Store tool description in zero-indexed
; Array.
set global.toolTable[var.toolID-1] = var.toolDesc 

M118 P0 L2 S{"Stored tool #" ^ var.toolID ^ ": " ^ var.toolDesc}