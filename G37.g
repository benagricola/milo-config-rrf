; G37.g
; Probe the current tool length and save its' offset.
; We calculate the offset based on the height of the
; toolsetter, and its' offset to the material surface
; we're working with.
;
; Operators _must_ call G6013 before this macro,
; as the reference surface must be probed with a touch
; probe, which will interfere with the tool changing
; process.
; You should call G6013 in the preamble of your gcode
; file, if you are expecting to have to change tools.
;
;
; USAGE: "G37"
;
; NOTE: This is designed to work with a NEGATIVE Z - that is, MAX is 0 and MIN is -<something>

M5       ; stop spindle just in case

G21      ; Switch to mm

G27 C1   ; park spindle

; Variables used to store tool position references.
var expectedToolZ   = global.referenceSurfaceZ + global.toolSetterHeight ; Expected toolsetter activation height
                                                                         ; if tool has exactly the same stickout
                                                                         ; as the touch probe used to probe the
                                                                         ; reference surface.
 
var actualToolZ     = 0 ; Actual Z co-ordinate probed with tool
var toolOffset      = 0 ; The calculated offset of the tool

; Reset tool Z offset
if { state.currentTool == -1 }
    abort {"No tool selected, run T<N> to select a tool!"}


if { var.expectedToolZ == 0 }
    abort {"Expected tool height is not properly probed!"}

G10 P{state.currentTool} Z0

M118 P0 L2 S{"Probing tool length at X=" ^ global.toolSetterX ^ ", Y=" ^ global.toolSetterY }

; Probe tool length multiple times and average
; Allow operator to jog tool over bolt after rough probing move to confirm
; lowest tool point.
G6012 X{global.toolSetterX} Y{global.toolSetterY} S{global.zMax} B{global.toolSetterDistanceZ} I{global.toolSetterJogDistanceZ} J1 K{global.toolSetterID} C{global.toolSetterNumProbes} V{global.toolSetterProbeSpeed}

; Park.
G27 C1

; Our tool offset is the difference between our expected tool Z and our actual
; tool Z. Expected tool Z is calculated during G6013 by probing the reference
; surface and then adding the offset of the toolsetter to it.
set var.actualToolZ = global.probeCoordinateZ
set var.toolOffset = var.actualToolZ - var.expectedToolZ
M118 P0 L2 S{"Expected Tool Z =" ^ var.expectedToolZ ^ ", Actual Tool Z=" ^ var.actualToolZ ^ " Tool Offset = " ^ var.toolOffset }

G10 P{state.currentTool} X0 Y0 Z{-var.toolOffset}



