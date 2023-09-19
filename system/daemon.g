; Update led colours based on printer / network status
while global.daemonEnable
    G4 P{global.daemonUpdateRate} ; Minimum interval between daemon runs

    if { exists(global.featureLeds) && global.featureLeds == true && global.ledsEnabled }
        M98 P"macros/misc/update-leds.g" ; Update LEDs based on machine status

    ; Only run VSSC when enabled
    if { exists(global.featureVSSC) && global.featureVSSC == true && global.vsscEnabled }
        M98 P"macros/tool/update-vssc.g" ; Update active spindle speed based on timings