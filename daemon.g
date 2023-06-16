; Fysetc 128x64 has _three_ LEDs but we treat 2 and 3 as the same
; since these are left and right of the rotary encoder.
var neopixelColours = {{0, 0, 0, 0}, {0, 0, 0, 0}}

; Update neopixel colours based on printer / network status
while global.neopixelUpdates
    G4 P{global.neopixelUpdateRate} ; Slow rate of updates

    ; Calculate screen background - LED 1 - based on RRF status
    var status = state.status
    if var.status == "starting"
        set var.neopixelColours[0] = global.neopixelColourStartup
    elif var.status == "updating" || var.status == "resuming"
        set var.neopixelColours[0] = global.neopixelColourWarning
    elif var.status == "halted"
        set var.neopixelColours[0] = global.neopixelColourError
    elif var.status == "paused"
        set var.neopixelColours[0] = global.neopixelColourPaused
    elif var.status == "cancelling" || var.status == "changingTool"
        set var.neopixelColours[0] = global.neopixelColourCancelling
    elif var.status == "processing" || var.status == "busy"
        set var.neopixelColours[0] = global.neopixelColourBusy
    elif var.status == "idle"
        set var.neopixelColours[0] = global.neopixelColourReady


    ; Calculate rotary encoder background - LED 2/3 - based on first
    ; network interface status.
    var netStatus = network.interfaces[0].state
    if var.netStatus == "disabled"
        set var.neopixelColours[1] = global.neopixelColourStartup
    elif var.netStatus == "enabled"
        set var.neopixelColours[1] = global.neopixelColourPaused
    elif var.netStatus == "starting1" || var.netStatus == "starting2"
        set var.neopixelColours[1] = global.neopixelColourWarning
    elif var.netStatus == "changingMode"
        set var.neopixelColours[1] = global.neopixelColourCancelling
    elif var.netStatus == "establishingLink"
        set var.neopixelColours[1] = global.neopixelColourBusy
    elif var.netStatus == "connected" || var.netStatus == "active"
        set var.neopixelColours[1] = global.neopixelColourReady

    ; No default colours for unrecognized states so previous
    ; colour will be used.

    ; Change LEDs once pin assigned
    if global.neopixelReady
        ; Set screen background colour (1 LED)
        M150 K0 R{var.neopixelColours[0][0]} U{var.neopixelColours[0][1]} B{var.neopixelColours[0][2]} P{var.neopixelColours[0][3]} S1 F1
        ; Set rotary encoder colour (2 LEDs)
        M150 K0 R{var.neopixelColours[1][0]} U{var.neopixelColours[1][1]} B{var.neopixelColours[1][2]} P{var.neopixelColours[1][3]} S2 F0

