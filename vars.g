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

; Probed co-ordinates
global touchProbeCoordinateX=0
global touchProbeCoordinateY=0

; Toolsetter and Touchprobe IDs
global toolSetterID=1
global touchProbeID=2

; Motor Settings
global motorMicroSteps=32
global motorStepDegrees=1.8
global leadScrewPitch=8

; Spindle settings
global spindleID=1
global spindleMinRPM=0         ; Note BOM / Chinese spindles generally don't like
                               ; running at lower than 8000RPM. Don't override
                               ; this unless you know your spindle can handle it.
global spindleMaxRPM=24000
global spindlePWMFrequency=40

; Used for both touch probe and toolsetter
global probeCoordinateZ=0

; Z height of reference surface
global referenceSurfaceZ=0

; Expected Z height of toolsetter switch activation point
global expectedToolZ=0

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

global hsscPreviousAdjustmentTime=0
global hsscPreviousAdjustmentRPM=0.0
global hsscPreviousAdjustmentDir=true

; Logging settings
global logFilePath="/sys/log"
global logFileNum=3
global logFileName="rrf.log"