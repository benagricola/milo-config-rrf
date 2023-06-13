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
global yHome=215
global yHomeRepeat=5
global zMin=-120
global zMax=0
global zHome=125
global zHomeRepeat=-5

; Toolsetter measurements
; Nose Offset is the Z height where the spindle nose activates the toolsetter
; Max length is the maximum length of the exposed tool 
global toolsetterSpindleNoseOffset=-102.7
global toolsetterX=0             ; X position of center of toolsetter
global toolsetterY=93.5          ; Y position of center of toolsetter
global toolsetterMaxLength=50    ; Height above toolsetterSpindleNoseOffset to
                                 ; start probing from (so 50 would start probing
                                 ; from -52.7).
global toolsetterNumProbes=5     ; Number of times to activate the toolsetter
                                 ; to calculate an average.
global toolsetterProbeSpeed=120  ; Feed rate to probe at in the Z direction.
global toolsetterTravelSpeed=600


; Touch probe measurements
global touchProbeDistanceXY=2    ; Distances that probe will be driven
global touchProbeDistanceZ=2     ; towards X, Y and Z faces of work piece.
                                 ; These values should be _lower_ than the
                                 ; over-travel protection of the touch probe
                                 ; being used, so as not to cause damage to
                                 ; the probe in the event of a failure to
                                 ; trigger.

                                 ; This also means that the touch probe must
                                 ; be within this range of the surface being
                                 ; probe
global touchProbeProbeSpeed=50
global touchProbeTravelSpeed=600

; Logging settings
global logFilePath="/sys/log"
global logFileNum=3
global logFileName="rrf.log"