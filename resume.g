M3 R1                ; Restore the spindle speed from before the pause
G4 S15               ; Wait for the spindle the get up to speed
G0 R1 X0 Y0          ; Go back to the last cut move X y Position - avoiding items on the spoilboard
G0 R1 X0 Y0 Z10      ; Go to 5mm above position of the last cut move
