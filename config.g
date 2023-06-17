; Configuration file for Fysetc Spider King 407 Version

; General preferences
M550 P"Millenium Milo v1.5 M016"     ; Set mill name
M453                                 ; Put RRF into CNC mode

M98 P"user-vars.g"
M98 P"vars.g"
M98 P"screen.g" ; Screen enabled early to allow boot feedback via LED's
M98 P"estop.g"
M98 P"logging.g"
M98 P"override-defaults.g"
M98 P"drives.g"
M98 P"speed.g"
M98 P"limits.g"
M98 P"toolsetter.g"
M98 P"touchprobe.g"
M98 P"fans.g"
M98 P"tool1.g"
M98 P"network.g"