; general.g
; Configures general machine settings
M453                       ; Enable CNC Mode
M550 P{global.machineName} ; Set machine name

M140 H-1 ; Disable heated bed (overrides default heater mapping)
