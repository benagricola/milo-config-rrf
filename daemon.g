; Update led colours based on printer / network status
while global.daemonEnable
    G4 P{global.daemonUpdateRate} ; Minimum interval between daemon runs

    if { exists(global.featureLeds) && global.featureLeds == true && global.ledsEnabled }
        M98 P"update-leds.g" ; Update LEDs based on machine status

    ; Only run HSSC when enabled
    if { exists(global.featureHSSC) && global.featureHSSC == true && global.hsscEnabled }
        M98 P"update-hssc.g" ; Update active spindle speed based on timings