; leds.g
; Configures LED strings if featureLeds is enabled

if {exists(global.featureLeds) && global.featureLeds }
    ; led LED control
    M950 E0 C{global.pinLed} T1 L300:800:1250:250
    set global.ledsReady = true