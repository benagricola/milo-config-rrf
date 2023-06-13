; Probe WCS Zero based on the top and outside surfaces of a work piece.

M5       ; stop spindle just in case

G28      ; home all axes

G27      ; park spindle

M291 P"Install touch probe and PLUG IT IN" R"Installation check" S2	

; TODO: Check status of probe in object model to confirm it is connected.

M118 P0 L2 S{"Probing reference surface at X=" ^ global.touchProbeReferenceX ^ ", Y=" ^ global.touchProbeReferenceY }

; Move probe above surface
G53 G0 X{global.touchProbeReferenceX} Y{global.touchProbeReferenceY}

; Switch to mm / relative positions for repeated probing
G21
G91

; Probe reference surface multiple times and average.
M98 P"touchprobe-z.g"
var referenceZ = global.touchProbeCoordinate
M118 P0 L2 S{"Reference Surface Z=" ^ referenceZ}

; Park
G27

M291 P"Jog the Touch Probe above the centre of the workpiece" R"Find height of work piece" S3 X1 Y1

; Probe material surface multiple times and average.
M98 P"touchprobe-z.g"
var materialZ = global.touchProbeCoordinate
M118 P0 L2 S{"Material Surface Z=" ^ materialZ}

; Park
G27



