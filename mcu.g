; mcu.g
; Loads hardware-specific settings for supported platforms

; Board 0 is the main MCU which is all we care about right now
var mcuType={boards[0].name}
var mcuFile={"mcu/" ^ var.mcuType ^ ".g"}


M118 P0 L2 S{"MCU Type: " ^ var.mcuType ^ " MCU File: " ^ var.mcuFile }
; Check if a pin file exists
;if { !fileexists(var.mcuFile) }
;    abort {"MCU type " ^ var.mcuType ^ " is not supported!"}

; All machines must have:
; - At least one emergency stop button 
; - Endstops for X, Y and Z
; - A spindle with RPM and enable output pins
; - An MCU Fan

M98 P{var.mcuFile}

; Check required pins are defined
; Edit this at your own peril!
if { !exists(global.pinEStop1) && !exists(global.pinEstop2) }
    abort {"No emergency stop pins defined for MCU type " ^ var.mcuType }
if { !exists(global.pinXStop) }
    abort {"No X endstop pin defined for MCU type " ^ var.mcuType }
if { !exists(global.pinYStop) }
    abort {"No Y endstop pin defined for MCU type " ^ var.mcuType }
if { !exists(global.pinZStop) }
    abort {"No Z endstop pin defined for MCU type " ^ var.mcuType }
if { !exists(global.pinTool) }
    abort {"No Spindle tool pins defined for MCU type " ^ var.mcuType }
if { !exists(global.pinMCUFan) }
    abort {"No MCU Fan pin defined for MCU type " ^ var.mcuType }