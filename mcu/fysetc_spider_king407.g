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
global motorCurrentLimitX=1000
global motorCurrentLimitY=1000
global motorCurrentLimitZ=1000

; Set maximum axis speeds (used for travel moves)
; in millimeters per minute
global maxSpeedLimitX=1500
global maxSpeedLimitY=1500
global maxSpeedLimitZ=600