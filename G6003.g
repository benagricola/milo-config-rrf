; G6003: Repeatable surface (vertical) probe, Z axis

; Z Probing will move to the safe height (S) _before_ moving
; horizontally.

; Note: This macro allows you to select a probe to use (K=, passed to G38.2)
; Please check, and DOUBLE CHECK, you are using the right probe ID.
; If you use the wrong probe ID you will ALMOST CERTAINLY crash your tool or
; touch probe into something hard and break things.

; YOU HAVE BEEN WARNED!

; IF IN DOUBT: Make sure the tool is fully retracted upwards before
; running this macro to lessen the chances of running the probe
; into anything on the work surface.

; Switch to mm / relative positions for repeated probing.
G21
G91

var retries       = 0
var probePos      = 0
var curPos        = 0

; Check if touchprobe feature is available
if {!exists(global.featureTouchProbe) || !global.featureTouchProbe }
    abort "Unable to probe material without touch probe!"

if { !exists(param.X) || !exists(param.Y) }
    { abort "Must provide starting position (X.., Y..)!" }

if { !exists(param.S) }
    { abort "Must provide a safe height (S..) to retreat to after probing for subsequent moves!" }

if { !exists(param.B) }
    { abort "Must provide a backoff height (B..) to retreat to after each probe!" }

if { !exists(param.K) }
    { abort "Must provide a sensor (K..) to use as probe!" }

if { !exists(param.C) }
    { abort "Must provide a number of probes (C..) to run!" }

if { !exists(param.A) }
    { abort "Must provide a vertical (V..) probe speed!" }

if { exists(param.J) && !exists(param.I) }
    { abort "Must provide a backoff height (I..) for operator jogging!"}

if { global.confirmUnsafeMove }
    M291 P{"Move to X=" ^ param.X ^ ", Y=" ^ param.Y ^ " at safe Z=" ^ param.S ^ ", probe #" ^ param.K ^ " towards Z=" ^ global.zMin ^ "?"} R"Safety check" S3

; Absolute moves to find starting position
G90

; Move to safe height
G53 G0 Z{param.S}

; Move to starting position
G53 G0 X{param.X} Y{param.Y}

; Back to relative moves for probing
G91

; Add a probe retry to account for the initial
; high-speed probe.
while var.retries <= param.C
    ; Probe towards surface.
    ; Z probes only run in one direction
    G53 G38.2 K{param.K} Z{global.zMin}
    
    ; Record current position
    set var.curPos = move.axes[2].machinePosition

    ; Reset all speed limits after probe
    M98 P"speed.g"

    ; If this is not the initial rough probe, record the position
    if var.retries > 0
        ; Add probe position for averaging
        set var.probePos = var.probePos+var.curPos

        M118 P0 L2 S{"Probe " ^ var.retries ^ "/" ^ param.C ^ ": Z=" ^ var.curPos}

        ; Move away from the trigger point
        G53 G0 Z{param.B}
 
    ; Otherwise, reduce the probe speed to increase accuracy
    else
        if { exists(param.J) && param.J == 1}
            ; Move away from the trigger point for tool jogging
            G53 G0 Z{param.I}

            ; Z movement is allowed as well because we might need to jog the tool
            ; upwards to position the lowest point over the switch if param.B is
            ; not high enough.
            M291 P"Fine-tune the probe location" R"Fine Tuning" S3 X1 Y1 Z1
        else
            ; Move away from the trigger point
            G53 G0 Z{param.B}

    ; Drop speed in probe direction for next probe attempt
    M203 Z{param.A}

    ; Iterate retry counter
    set var.retries = var.retries + 1

; Make sure to reset all speed limits after probing complete
M98 P"speed.g"

var probePosAveraged = var.probePos / param.C

M118 P0 L2 S{"Z=" ^ var.probePosAveraged}

; Absolute moves to find ending position
G90

; Move to safe height
G53 G0 Z{param.S}

set global.probeCoordinateZ=var.probePosAveraged