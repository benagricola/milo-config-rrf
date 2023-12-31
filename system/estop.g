; Configure Physical Emergency Stop on Machine

M950 J1 C{global.pinEStop1} ; Configure emergency stop pin
M581 P1 T0 S1 R0            ; Fire trigger 0 (emergency stop) on status change

if { global.featureCasa && exists(global.pinEStop2) }
    M950 J2 C{global.pinEStop2} ; Configure emergency stop pin
    M581 P2 T0 S1 R0

if { global.checkEstopOnBoot }
    M118 P0 L2 S{"Pausing boot until all emergency stops are inactive"}
    M582 T0 ; Check estops not active before continuing startup
    M118 P0 L2 S{"All emergency stops are inactive, continuing boot"}
