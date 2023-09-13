; DO NOT CHANGE ANY SETTINGS HERE.
; These values are used as returns 
; from macros or where global
; flags are needed.

; Disable all features by default
global featureLeds=false
global featureCasa=false
global featureScreen=false
global featureToolSetter=false
global featureTouchProbe=false
global featureHSSC=false

; Axis Settings
; Min:  Axis Minimum
; Max:  Axis Maximum
; Home: Direction and distance to move towards endstops
; Repeat: Direction and distance to move away from endstops when repeating probe
; Home and Repeat MUST be in opposite directions otherwise you will crash into
; your endstops.
; Do not override these unless you have changed the dimensions of your
; machine!
global xMin=0
global xMax=335
global xHome=-345
global xHomeRepeat=5
global yMin=0
global yMax=208
global yHome=215
global yHomeRepeat=-5
global zMin=-120
global zMax=0
global zHome=125
global zHomeRepeat=-5

; Machine will initially home at the machine
; speed limits using G0 and then repeat
; the homing operation at the following speeds.
global zHomeRepeatSpeed=180  ; mm/min
global xyHomeRepeatSpeed=180 ; mm/min

; Probed co-ordinates
global touchProbeCoordinateX=0
global touchProbeCoordinateY=0
global touchProbeConnected=false

; Toolsetter and Touchprobe IDs
global toolSetterID=1
global touchProbeID=2

; Motor Settings
global motorMicroSteps=32
global motorStepDegrees=1.8
global leadScrewPitch=8

; Default motor performance settings, these will be
; overridden by MCU configuration where appropriate

; Set motor current limits in milliamps.
global motorCurrentLimitX=1000
global motorCurrentLimitY=1000
global motorCurrentLimitZ=1000

; Set maximum axis speeds (used for travel moves)
; in millimeters per minute
global maxSpeedLimitX=1000
global maxSpeedLimitY=1000
global maxSpeedLimitZ=300

; Set maximum acceleration speeds
; in mm/s^2
global maxAccelLimitX=500
global maxAccelLimitY=500
global maxAccelLimitZ=60

; Set maximum instantaneous speed changes
; in mm/min
global maxJerkLimitX=60
global maxJerkLimitY=60
global maxJerkLimitZ=10

; Spindle settings
global spindleID=1             ; The tool ID of the Milo spindle.
global spindleMinRPM=8000      ; Note BOM / Chinese spindles generally don't like
                               ; running at lower than 8000RPM. Don't override
                               ; this unless you know your spindle can handle it.
global spindleMaxRPM=24000
global spindlePWMFrequency=10

; Allow up to 50 tools to be stored.
; Note that RRF arrays cannot be expanded once
; defined, so pick a large enough number here to
; accommodate as many tools as we can.
global toolDefaultName="Unknown Tool"
global toolTable=vector(50,global.toolDefaultName) ; Tools can be passed from postprocessor
                                                   ; using M6000 or defined here manually.

global originCorners = {"Front Left","Front Right","Rear Left","Rear Right"}
global originAll     = {"Front Left","Front Right","Rear Left","Rear Right","Center"}

global wcsNames          = {"G54","G55","G56","G57","G58","G59","G59.1","G59.2","G59.3"}

; Used for both touch probe and toolsetter
global probeCoordinateZ=0

; Z height of reference surface
global referenceSurfaceZ=0

; Expected Z height of toolsetter switch activation point
global expectedToolZ=0

global homeRepeatSpeed=180

global ledsEnabled=false
global ledsReady=false ; Do not change, used to avoid addressing
                       ; LEDs before pin has been assigned.

global ledColourWarning={255, 255, 0, 255}    ; Yellow
global ledColourCancelling={255, 165, 0, 255} ; Yellow
global ledColourError={255, 0, 0, 255}        ; Red
global ledColourStartup={255, 255, 255, 255}  ; White
global ledColourReady={0, 255, 0, 255}        ; Green
global ledColourBusy={0, 0, 255, 255}         ; Blue
global ledColourPaused={0, 255, 255, 255}     ; Cyan

global hsscEnabled=false
global hsscPeriod=0
global hsscVariance=0
global hsscDebug=false
global hsscSpeedWarningIssued=false
global hsscPreviousAdjustmentTime=0
global hsscPreviousAdjustmentRPM=0.0
global hsscPreviousAdjustmentDir=true

; Logging settings
global logFilePath="/sys/log"
global logFileNum=3
global logFileName="rrf.log"