; Free Tool 1
M118 P0 L2 S"Tool 1: Freeing and spinning down..."
M5
G4 S15    ; Stop tool and wait for it to spin down
G10 P1 Z0 ; reset tool offset
M118 P0 L2 S"Tool 1: Tool offset reset..."
G90       ; absolute positioning
G1 Z0     ; lift Z to 0 to avoid crashing during moves
G91
