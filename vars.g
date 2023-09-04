
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
global spindleMaxRPM=24000
global spindlePWMFrequency=100

; Used for both touch probe and toolsetter
global probeCoordinateZ=0

; Z height of reference surface
global referenceSurfaceZ=0

; Expected Z height of toolsetter switch activation point
global expectedToolZ=0

global ledsReady=false ; Do not change, used to avoid addressing
                       ; LEDs before pin has been assigned.
