; Fans

; Configure fan port 0 as the MCU Fan
M950 F0 C{global.pinMCUFan} Q500

; Enable fan port 0 and leave it running
M106 P0 S1 H-1

; Disable fan port 1
M950 F1 C"nil"

