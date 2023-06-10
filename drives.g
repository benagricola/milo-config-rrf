; Configure Drives

M569 P0 S1                           ; Physical drive 0 (X) goes forwards using default driver timings
M569 P1 S1                           ; Physical drive 1 (Y) goes forwards using default driver timings
M569 P2 S1                           ; Physical drive 2 (Z) goes forwards using default driver timings

M584 X0 Y1 Z2                        ; Set drive mapping
M350 X64 Y64 Z64 I1                  ; configure microstepping with interpolation
M92 X1600.00 Y1600.00 Z3200.00       ; Set steps per mm. Z is geared 2:1

M906 X2000 Y2000 Z2000               ; Set motor currents (mA)

M84                                  ; Disable motor idle current reduction
