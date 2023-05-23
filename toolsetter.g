; Toolsetter

; Note: repeat probing doesn't seem to be triggered
; using M585.
M558 K1 P8 C"^xstopmax" H30 A10 S0.01 T600 F120 ; Z-probe ID 1
						; Type 8 (unfiltered digital)
                                                ; NC Switch
                                                ; Pin xstopmax, pulled up
                                                ; Probing starts at +30mm
                                                ; Max 10 probes
                                                ; Maximum variance 0.01

