; Neopixel LED control
M950 E0 C"^LCDD5" T1 L300:800:1250:250

; Enable screen 
M918 P2 E2 F2000000   

G4 S2

; Set all LED's yellow
M150 K0 R255 U255 B0 P150 S3 F0
