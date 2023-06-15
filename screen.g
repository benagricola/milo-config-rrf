; Neopixel LED control
M950 E0 C"^LCDD5" T1 L300:800:1250:250

; Enable screen 
M918 P2 E2 F2000000   

G4 S2

; Set all LED's red
M150 K0 R255 U0 B0 P255 S3 F0
