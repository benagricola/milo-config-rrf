; Hardware Settings for FYSETC Spider King STM32F407
; Define pins used for configuring hardware

; Endstop Pins.
; These should be negated (^) as endstops should always
; be wired in a normally closed configuration.
global pinXStop="^xstop"
global pinYStop="^ystop"
global pinZStop="^zstop"

; Emergency Stop Pins.
; These should also always be negated (^) as emergency systems
; should always be wired normally closed.
global pinEStop1="^ystopmax" ; Estop1 is generally on the machine
global pinEStop2="^ystopmax" ; Estop2 may be on an enclosure
                             ; TODO: Fix, these conflict. We need to move these to {x,y}stopmax
                             ; and then move pinToolSetter to zstopmax.

global pinTool="he0+^fan1"   ; First pin is for PWM output of RPM, second pin is enable output.

; MCU / Driver Fan Pins and Tacho
global pinMCUFan="!fan0+tacho0"

; Toolsetter Pin, only used when feature enabled
global pinToolSetter="^xstopmax"

; Touchprobe Pin, only used when feature enabled
global pinTouchProbe="!probe"

; LED Pin, only used when feature enabled 
global pinLed="^LCDD5"

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