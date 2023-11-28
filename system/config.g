; config.g: Load modular configuration for Milo CNC Mill


; DO NOT EDIT. All user configuration can be made in user-vars.g

; Load Vars once
if { !exists(global.varsLoaded) }
    M98 P"vars.g"
    global varsLoaded = true

; Load MCU configuration once
if { !exists(global.mcuLoaded) }
    M98 P"mcu.g"
    global mcuLoaded = true

; Load User Vars once
if { !exists(global.userVarsLoaded) }
    M98 P"user-vars.g"
    global userVarsLoaded = true

; If MCU config or any vars need updating,
; you must restart the MCU (use M999).

M98 P"leds.g"
M98 P"general.g"
M98 P"estop.g"
M98 P"logging.g"
M98 P"drives.g"
M98 P"speed.g"
M98 P"limits.g"
M98 P"toolsetter.g"
M98 P"touchprobe.g"
M98 P"fans.g"
M98 P"tool1.g"
M98 P"network.g"
M98 P"screen.g"