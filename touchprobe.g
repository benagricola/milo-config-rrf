; Touch Probe

; Note: repeat probing doesn't seem to be triggered
; using M585.
M558 K2 P8 C{global.pinTouchProbe} H5 A10 S0.01 T{global.touchProbeRoughSpeed} F{global.touchProbeRoughSpeed} ; Probe ID 2
                                                                                                    ; Type 8 (unfiltered digital)
                                                                                                    ; NC Switch
                                                                                                    ; Pin zstopmax, pulled up
                                                                                                    ; Probing starts at +5mm
                                                                                                    ; Max 10 probes
                                                                                                    ; Maximum variance 0.01

