; Network
M551 P{global.dwcPassword} ; Set Duet Web Control password

; Disable WiFi, Dwell, enable WiFi and HTTP only
M552 S0

; Wait for wifi module to acknowlede idle
M8000 C0 S"disabled" M30

; Enable WiFi adapter in correct mode.
M552 S{global.wifiAccessPoint ? '2' : '1'}

; Wait for WIFI to be enabled
M8000 C0 S"active" M30

M586 P0 S1  ; enable HTTP
M586 P1 S0  ; disable FTP
M586 P2 S0  ; disable Telnet 

