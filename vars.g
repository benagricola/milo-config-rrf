; Min:  Axis Minimum
; Max:  Axis Maximum
; Home: Direction and distance to move towards endstops
; Repeat: Direction and distance to move away from endstops when repeating probe
; Home and Repeat MUST be in opposite directions otherwise you will crash into
; your endstops.

global xMin=0
global xMax=335
global xHome=-345
global xHomeRepeat=5
global yMin=0
global yMax=209
global yHome=-165
global yHomeRepeat=5
global zMin=-120
global zMax=0
global zHome=125
global zHomeRepeat=-5

; Toolsetter measurements
; Nose Offset is the Z height where the spindle nose activates the toolsetter
; Max length is the maximum length of the exposed tool 
global toolsetterSpindleNoseOffset=-102.7
global toolsetterX=0
global toolsetterY=93.5
global toolsetterMaxLength=50
