; Define pins used for configuring hardware
global pinEStop="^ystopmax"
global pinXStop="^xstop"
global pinYStop="^ystop"
global pinZStop="^zstop"

global pinNeoPixel="^LCDD5"
global pinFan0="!fan0+tacho0"

global pinTool="he0+^fan1"
global pinToolSetter="^xstopmax"
global pinTouchProbe="!probe"


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
global touchProbeNumProbes=5
global touchProbeDistanceXY=2     ; Distances that probe will be driven
global touchProbeDistanceZ=2      ; towards X, Y and Z faces of work piece.
                                  ; These values should be _lower_ than the
                                  ; over-travel protection of the touch probe
                                  ; being used, so as not to cause damage to
                                  ; the probe in the event of a failure to
                                  ; trigger.

                                  ; This also means that the touch probe must
                                  ; be within this range of the surface being
                                  ; probed.
global touchProbeSafeDistanceZ=10 ; Safe distance above probed work surface for
                                  ; non-probing X/Y moves.
global touchProbeReferenceX=0     ; X,Y co-ordinates of the reference surface to
global touchProbeReferenceY=65    ; use. The reference surface is a known surface
                                  ; from which offsets can be calculated. The distance
                                  ; in Z from the reference surface to the touch-
                                  ; probe activation point allows us to compensate for
                                  ; the length of the touch probe and tools. 

global touchProbeMaxLength=70     ; This is the total length of the touch probe
                                  ; when not installed in the spindle (including shank).
                                  ; It gives us a safe offset to probe downwards from
                                  ; so we do not have to probe from Z=0
global touchProbeProbeSpeed=100
global touchProbeTravelSpeed=600
global touchProbeDwellTime=500    ; Time to pause after backing away from a surface
                                  ; before repeating a probe, to allow the machine
                                  ; to settle.

;global touchProbeConfirmMove=true
                                  ; Set this to false to move automatically to
                                  ; calculated probe locations. ONLY DO THIS WHEN
                                  ; YOU ARE CERTAIN THAT THE PROBING MACRO WORKS
                                  ; PERFECTLY FOR YOUR SETUP.

; Do not set, these are used as return values from the touch probe macros
global touchProbeCoordinateX=0
global touchProbeCoordinateY=0
global touchProbeCoordinateZ=0

; Parking settings
global parkX=global.xMax/2 ; Park with the "bed" approximately in the middle
global parkY=global.yMax   ; and at the front for operator ease-of-use.
global parkZ=global.zMax   ; Think VERY hard before parking this anywhere else
                           ; except Z=0 (zMax)

; Logging settings
global logFilePath="/sys/log"
global logFileNum=3
global logFileName="rrf.log"