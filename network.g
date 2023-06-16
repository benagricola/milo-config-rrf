; Network
M551 P"rrf" ; set password

; Disable WiFi, Dwell, enable WiFi and HTTP only
M552 S0

; TODO: Wait for wifi to be disabled
; network.interfaces[].state

G4 S5

M552 S2

; Wait for WIFI to be enabled

M586 P0 S1  ; enable HTTP
M586 P1 S0  ; disable FTP
M586 P2 S0  ; disable Telnet 

