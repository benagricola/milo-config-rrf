if {exists(global.featureLeds) && global.featureLeds == true }
    ; Fysetc 128x64 has _three_ LEDs but we treat 2 and 3 as the same
    ; since these are left and right of the rotary encoder.
    var ledColours = {{0, 0, 0, 0}, {0, 0, 0, 0}}

    ; Update led colours based on printer / network status
    while global.ledUpdates
        G4 P{global.ledUpdateRate} ; Slow rate of updates

        ; Calculate screen background - LED 1 - based on RRF status
        var status = state.status
        if var.status == "starting"
            set var.ledColours[0] = global.ledColourStartup
        elif var.status == "updating" || var.status == "resuming"
            set var.ledColours[0] = global.ledColourWarning
        elif var.status == "halted"
            set var.ledColours[0] = global.ledColourError
        elif var.status == "paused"
            set var.ledColours[0] = global.ledColourPaused
        elif var.status == "cancelling" || var.status == "changingTool"
            set var.ledColours[0] = global.ledColourCancelling
        elif var.status == "processing" || var.status == "busy"
            set var.ledColours[0] = global.ledColourBusy
        elif var.status == "idle"
            set var.ledColours[0] = global.ledColourReady


        ; Calculate rotary encoder background - LED 2/3 - based on first
        ; network interface status.
        var netStatus = network.interfaces[0].state
        if var.netStatus == "disabled"
            set var.ledColours[1] = global.ledColourStartup
        elif var.netStatus == "enabled"
            set var.ledColours[1] = global.ledColourPaused
        elif var.netStatus == "starting1" || var.netStatus == "starting2"
            set var.ledColours[1] = global.ledColourWarning
        elif var.netStatus == "changingMode"
            set var.ledColours[1] = global.ledColourCancelling
        elif var.netStatus == "establishingLink"
            set var.ledColours[1] = global.ledColourBusy
        elif var.netStatus == "connected" || var.netStatus == "active"
            set var.ledColours[1] = global.ledColourReady

        ; No default colours for unrecognized states so previous
        ; colour will be used.

        ; Change LEDs once pin assigned
        ; Fysetc 128x64 colour seems to flip green and red?
        if global.ledsReady
            ; Set screen background colour (1 LED)
            M150 K0 R{var.ledColours[0][0]} U{var.ledColours[0][1]} B{var.ledColours[0][2]} P{var.ledColours[0][3]} S1 F1
            ; Set rotary encoder colour (2 LEDs)
            M150 K0 R{var.ledColours[1][0]} U{var.ledColours[1][1]} B{var.ledColours[1][2]} P{var.ledColours[1][3]} S2 F0

