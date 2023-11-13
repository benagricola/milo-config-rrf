; G6000.g
; Use Duet Web Control dialogs to gather the required information
; to perform cuboid work piece probing, and then run G6000.1 with
; these details.

; USAGE: "G6000"
; 
; NOTE: MUST be used with a negative Z (so 0 to -<n> rather than 0 to <n>)

G27      ; park spindle away from work piece so we know we're
         ; starting from a safe location.

; Variables used to store user inputs.
var materialOpLenX  = null
var materialOpLenY  = null
var probeDistanceZ  = null
var zeroWCS         = null

; Prompt user to enter the approximate length of the workpiece (X)
; X is length because it is the longest axis
M291 P{"Enter approximate length of work piece in X (left to right, facing machine). If unsure, guess high."} R"Work piece length" S5 T0 J1 L10 F{global.xMax - global.xMin}
if input !=  null
    set var.materialOpLenX = input

; Prompt user to enter the approximate width of the workpiece (Y)
M291 P{"Enter approximate width of work piece in Y (front to back, facing machine). If unsure, guess high."} R"Work piece width" S5 T0 J1 L10 F{global.yMax - global.yMin}
if input != null
    set var.materialOpLenY = input

; Prompt user for a probe depth for edges
M291 P{"Select probe depth from material surface when probing edges"} R"Probe depth" S4 T0 J1 K{"-2mm","-4mm","-6mm","-8mm","-10mm"}
if input != null
    set var.probeDistanceZ = { (input + 1) * 2 }

; Prompt user for WCS index to zero
M291 P"Select WCS to set X=0, Y=0, Z=0 on" R"WCS to zero" S4 T0 J1 K{global.wcsNames}
if input != null
    ; Add 1 to the selection because we get a zero-indexed number
    set var.zeroWCS = input+1

; Call macro with arguments
if { var.materialOpLenX != null && var.materialOpLenY != null && var.probeDistanceZ != null && var.zeroWCS != null }
    G6000.1 I{var.probeDistanceZ} X{var.materialOpLenX} Y{var.materialOpLenY} W{var.zeroWCS}