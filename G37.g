; Probe the current tool length and save its' offset.
; Offset is in relation to the spindle nose.

; NOTE: This is designed to work with a NEGATIVE Z - that is, MAX is 0 and MIN is -<something>

; Vars
var startHeight          = global.toolsetterSpindleNoseOffset + global.toolsetterMaxLength

; Reset tool Z offset
G10 P{state.currentTool} Z0

; Move spindle away from the work piece carefully
G90                   ; absolute positioning
G21                   ; use MM
G53 G0 Z{global.zMax} ; lift Z to 0 to avoid crashing during moves

M118 P0 L2 S{"Tool " ^ state.currentTool ^ ": Moving to toolsetter position at height " ^ var.startHeight ^ ", expect trigger at " ^ global.toolsetterSpindleNoseOffset}

; Move the tool above the touch probe
G53 G0 X{global.toolsetterX} Y{global.toolsetterY} Z{var.startHeight}

M291 P"Jog the lowest point of the tool over the toolsetter" R"Find length of tool" S3 X1 Y1

; Switch to relative positions for repeated probing
G91

M118 P0 L2 S{"Tool " ^ state.currentTool ^ ": Probing, max tool length " ^ global.toolsetterMaxLength ^ "mm"}

var retries    = 1
var toolOffset = 0

; Run toolsetterNumProbes and average the offset.
while var.retries <= global.toolsetterNumProbes
    G53 M585 Z{global.toolsetterSpindleNoseOffset} F{global.toolsetterProbeSpeed} P1 S1 ; Probe tool length
    var curOffset = tools[state.currentTool].offsets[2]
    
    ; Get Z offset and add to offset tracker
    set var.toolOffset = var.toolOffset + var.curOffset

    M118 P0 L2 S{"Tool " ^ state.currentTool ^ ": Probe " ^ var.retries ^ "/" ^ global.toolsetterNumProbes ^ ": " ^ var.curOffset}

    ; Reset offset so we dont screw up any moves
    G10 P{state.currentTool} Z0

    G53 G0 Z10

    ; Iterate retry counter
    set var.retries = var.retries + 1

set var.toolOffset = var.toolOffset / global.toolsetterNumProbes

if var.toolOffset > 0
    {abort "Tool " ^ state.currentTool ^ ": ERROR - Probed a positive offset " ^ -var.toolOffset}

M118 P0 L2 S{"Tool " ^ state.currentTool ^ ": Stickout: " ^ -var.toolOffset}
G10 P{state.currentTool} Z{var.toolOffset}


G27                    ; Park spindle and bed



