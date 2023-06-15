; Configure Physical Emergency Stop

M950 J1 C{global.pinEStop} ; Configure emergency stop pin
M581 P1 T0 S1 R0     ; Fire trigger 0 (emergency stop) on status change
M582 T0              ; Check estop not active before continuing startup

