; Configuration file for Fysetc Spider King 407 Version

; General preferences
G90                                  ; Send absolute coordinates...
M83                                  ; ...But relative extruder moves
M550 P"Millenium Milo v1.5 Whiteout" ; Set mill name
M453                                 ; Put RRF into CNC mode

M98 P"vars.g"
M98 P"estop.g"
M98 P"logging.g"
M98 P"screen.g"
M98 P"override-defaults.g"
M98 P"drives.g"
M98 P"speed.g"
M98 P"limits.g"
M98 P"toolsetter.g"
M98 P"fans.g"
M98 P"spindle1.g"
M98 P"network.g"

