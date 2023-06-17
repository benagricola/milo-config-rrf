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

; Parking settings
global parkX={(global.xMax - global.xMin)/2} ; Park with the "bed" approximately in the middle
global parkY=global.yMax                     ; and at the front for operator ease-of-use.
global parkZ=global.zMax                     ; Think VERY hard before parking this anywhere else
                                             ; except Z=0 (zMax)

; NOTE: The touch probe and toolsetter work in tandem.
; When probing a surface, we don't know (and can't know)
; the probe stickout. But if we probe a reference surface
; (the X gantry face) and we know the absolute height 
; of the toolsetter switch from the reference surface
; when activated, we can calculate the offset between
; the height of the toolsetter switch (when a real tool is 
; being probed) and the top surface of the material we are
; trying to set as Z=0.

; This is calculated in the following manner:
; Reference Z (absolute)                           = -95.163
; Material Z (absolute)                            = -68.095
; Material Height                                  = 27.068
; Touch probe offset from Ref Z (toolsetterHeight) = 42.52
; Tool offset = Probe Offset - Material Height     = 15.452

; Esentially this means that the tool is 15.452mm SHORTER
; than the touch probe, so needs to be ADDED to Z (positive)
; tool offset. If the material is HIGHER than the toolsetter,
; then this would become a negative value 

; Used for both toolsetter and touch probe
global probeConfirmMove=true
                                  ; Set this to false to move automatically to
                                  ; calculated probe locations. ONLY DO THIS WHEN
                                  ; YOU ARE CERTAIN THAT THE PROBING MACROS WORK
                                  ; PERFECTLY FOR YOUR SETUP.

; Toolsetter measurements

global toolsetterHeight=42.5         ; Height of toolsetter sexbolt surface when activated.
                                     ; from touchprobe reference surface
global toolsetterX=0                 ; X position of center of toolsetter
global toolsetterY=93.5              ; Y position of center of toolsetter
global toolsetterDistanceZ=10        ; Once rough position of tool is found, back off
                                     ; to allow operator to jog tool over sexbolt.
                                       
global toolsetterNumProbes=5         ; Number of times to activate the toolsetter
                                     ; to calculate an average.
global toolsetterProbeSpeed=50       ; Feed rate to probe at in the Z direction.
global toolsetterProbeRoughSpeed=300 ; Feed rate to detect initial tool position


; Touch probe measurements
global touchProbeNumProbes=5
global touchProbeRadius=1         ; Radius of ball head on probe. Compensates for
                                  ; the direction in which the probe touches the surface
                                  ; when probing in X/Y directions.
global touchProbeDistanceXY=2     ; Distances that probe will be driven
global touchProbeDistanceZ=2      ; towards X, Y and Z faces of work piece.
                                  ; These values should be _lower_ than the
                                  ; over-travel protection of the touch probe
                                  ; being used, so as not to cause damage to
                                  ; the probe in the event of a failure to
                                  ; trigger.
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
global touchProbeProbeSpeed=25    ; Speed to probe at in mm/min when calculating surface
                                  ; offsets.
global touchProbeRoughSpeed=300   ; Initial probe towards a surface is performed at this
                                  ; speed in mm/min
global touchProbeDwellTime=0      ; Time to pause after backing away from a surface
                                  ; before repeating a probe, to allow the machine
                                  ; to settle.



; Neopixel settings
global neopixelUpdates=true   ; Auto-update neopixel colours based on printer and
                              ; network status.
global neopixelUpdateRate=500 ; Update neopixel colours every 500 milliseconds

global neopixelColourWarning={255, 255, 0, 255}    ; Yellow
global neopixelColourCancelling={255, 165, 0, 255} ; Yellow
global neopixelColourError={255, 0, 0, 255}        ; Red
global neopixelColourStartup={255, 255, 255, 255}  ; White
global neopixelColourReady={0, 255, 0, 255}        ; Green
global neopixelColourBusy={0, 0, 255, 255}         ; Blue
global neopixelColourPaused={0, 255, 255, 255}     ; Cyan

; Logging settings
global logFilePath="/sys/log"
global logFileNum=3
global logFileName="rrf.log"