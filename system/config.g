; config.g: Load modular configuration for Milo CNC Mill


; DO NOT EDIT. All user configuration can be made in user-vars.g

; Load Vars once
if { !exists(global.varsLoaded) }
    M98 P"system/vars.g"
    global varsLoaded = true

; Load MCU configuration once
if { !exists(global.mcuLoaded) }
    M98 P"system/mcu.g"
    global mcuLoaded = true

; Load User Vars once
if { !exists(global.userVarsLoaded) }
    M98 P"user-vars.g"
    global userVarsLoaded = true

; If MCU config or any vars need updating,
; you must restart the MCU (use M999).

M98 P"system/leds.g"
M98 P"system/general.g"
M98 P"system/estop.g"
M98 P"system/logging.g"
M98 P"system/drives.g"
M98 P"system/speed.g"
M98 P"system/limits.g"
M98 P"system/toolsetter.g"
M98 P"system/touchprobe.g"
M98 P"system/fans.g"
M98 P"system/tool1.g"
M98 P"system/network.g"
M98 P"system/screen.g"