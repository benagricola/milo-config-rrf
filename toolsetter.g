; Toolsetter

; Note: repeat probing doesn't seem to be triggered
; using M585.
M558 K1 P8 C{global.pinToolSetter} H30 A10 S0.01 T{global.toolsetterProbeRoughSpeed} F{global.toolsetterProbeRoughSpeed} ; Probe ID 1
						                                                                                                 ; Type 8 (unfiltered digital)
                                                                                                                         ; NC Switch
                                                                                                                         ; Pin xstopmax, pulled up
                                                                                                                         ; Probing starts at +30mm
                                                                                                                         ; Max 10 probes
                                                                                                                         ; Maximum variance 0.01

