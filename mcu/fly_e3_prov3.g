; Hardware Settings for Mellow Fly CDYv3
; Define pins used for configuring hardware

; Endstop Pins.
; These should be negated (^) as endstops should always
; be wired in a normally closed configuration.
global pinXStop="xstop"
global pinYStop="ystop"
global pinZStop="zstop"

; Emergency Stop Pins.
; These should also always be negated (^) as emergency systems
; should always be wired normally closed.
global pinEStop1="xstopmax" ; Estop1 is generally on the machine
global pinEStop2="ystopmax" ; Estop2 may be on an enclosure

global pinTool="bed+Laser"   ; First pin is for PWM output of RPM, second pin is enable output.

; MCU / Driver Fan Pins and Tacho
global pinMCUFan="fan0"

; Toolsetter Pin, only used when feature enabled
global pinToolSetter="e0stop"

; Touchprobe Pin, only used when feature enabled
global pinTouchProbe="!e1stop"

; LED Pin, only used when feature enabled 
global pinLed="^LCD_D5"

; Set motor current limits in milliamps.
; These can be overridden in user-vars if necessary.
set global.motorCurrentLimitX=1200
set global.motorCurrentLimitY=1200
set global.motorCurrentLimitZ=1200

; Set maximum axis speeds (used for travel moves)
; in millimeters per minute
set global.maxSpeedLimitX=3000
set global.maxSpeedLimitY=3000
set global.maxSpeedLimitZ=1000

; Set maximum acceleration speeds
; in mm/s^2
set global.maxAccelLimitX=800
set global.maxAccelLimitY=800
set global.maxAccelLimitZ=400

; Set maximum instantaneous speed changes
; in mm/min
set global.maxJerkLimitX=600
set global.maxJerkLimitY=600
set global.maxJerkLimitZ=400