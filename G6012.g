; G6012: Repeatable surface (vertical) probe, Z axis

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

; Switch to mm
G21

var retries       = 0

; These positions are absolute and negated at the end
; of the macro, to make reasoning about the logic
; simpler.
var probePos      = 0
var curPos        = 0
var probePosMin   = { abs(global.zMin) }
var probePosMax   = 0

; Confirm touch probe available and connected
G6999

if { !exists(param.X) || !exists(param.Y) }
    abort { "Must provide starting position (X.., Y..)!"  }

if { !exists(param.S) }
    abort { "Must provide a safe height (S..) to retreat to after probing for subsequent moves!"  }

if { !exists(param.B) }
    abort { "Must provide a backoff height (B..) to retreat to after each probe!"  }

if { !exists(param.K) }
    abort { "Must provide a sensor (K..) to use as probe!"  }

if { !exists(param.C) }
    abort { "Must provide a number of probes (C..) to run!"  }

if { !exists(param.V) }
    abort { "Must provide a vertical (V..) probe speed!"  }

if { exists(param.J) && !exists(param.I) }
    abort { "Must provide a backoff height (I..) for operator jogging!" }

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

; Our first probe is done down to zMin but
; once we've activated it once, we know approximately
; where we expect it to activate.
; We will not move further than -1mm below the initial
; activation point, which should limit damage in case of
; a probing failure after the operator jogs the tool
; away or onto a tooth. 

; Add a probe retry to account for the initial
; high-speed probe.
while var.retries <= param.C
    ; Probe towards surface.
    ; Z probes only run in one direction
    G53 G38.2 K{param.K} Z{-(var.probePosMin+1)}

    ; Abort if an error was encountered 
    if { result != 0 }
        ; Reset all speed limits after probe
        M98 P"speed.g"
        abort {"Probe experienced an error, aborting!"}
    
    ; Record current position
    set var.curPos = { abs(move.axes[2].machinePosition) }

    ; Increase Z speed for backing off
    ; Reduce acceleration
    M203 Z{global.touchProbeRoughSpeed}
    M201 Z{global.maxAccelLimitZ/2}

    ; If this is not the initial rough probe, record the position
    if var.retries > 0
        if { var.curPos > var.probePosMax }
            set var.probePosMax = var.curPos
        
        if { var.curPos < var.probePosMin }
            set var.probePosMin = var.curPos

        ; Add probe position for averaging
        set var.probePos = { var.probePos + var.curPos }

        M118 P0 L2 S{"Probe " ^ var.retries ^ "/" ^ param.C ^ ": Z=" ^ -var.curPos}

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
            M291 P"Fine-tune the location to probe" R"Fine Tuning" S3 X1 Y1 Z1
        else
            ; Move away from the trigger point
            G53 G0 Z{param.B}

    ; Drop speed in probe direction for next probe attempt
    M203 Z{param.V}
    
    M118 P0 L2 S{"Min=" ^ var.probePosMin ^ " Max=" ^ var.probePosMax }

    ; Dwell so machine can settle
    G4 P{global.touchProbeDwellTime}

    ; Iterate retry counter
    set var.retries = var.retries + 1

; Make sure to reset all speed limits after probing complete
M98 P"speed.g"

; If we have enough probe points, remove the highest and lowest
; points before averaging the rest.
var probePosAveraged = 0

if param.C > 3
    ; We use negative Z co-ordinates so we must _add_ the max and min to
    ; remove them from the calculation.

    M118 P0 L2 S{"Max=" ^ var.probePosMax ^ " Min="^ var.probePosMin ^ " Total=" ^ var.probePos }
    set var.probePosAveraged = {-((var.probePos - var.probePosMax - var.probePosMin) / (param.C-2)) }
else
    set var.probePosAveraged = {-(var.probePos / param.C)}

M118 P0 L2 S{"Z=" ^ var.probePosAveraged}

; Absolute moves to find ending position
G90

; Move to safe height
G53 G0 Z{param.S}

set global.probeCoordinateZ=var.probePosAveraged