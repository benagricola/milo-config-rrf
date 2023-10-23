; M8000.g
; Wait for network connection to enter requested state.
;
; Argument given in M will be divided by 10 for each
; retry, so M30 will delay and check 10 x 3 seconds
; before rebooting the machine.
;
; WARNING: Needless to say, this will reboot the machine
; when the timeout is reached. DO NOT RUN THIS DURING A
; MACHINING OPERATION!
;
; USAGE: "M8000 C<optional-network-index> S"<state>" M<optional-max-wait-in-seconds>"

var retries=0
var maxRetries=10
var waitTime=30
var connIndex=0

if { !exists(param.S) }
    abort { "Must specify state (S..) as string to check against network state" }

if { exists(param.M) }
    set var.waitTime = param.M

if { exists(param.C) }
    set var.connIndex = param.C

while { network.interfaces[var.connIndex].state != param.S }
    if { var.retries == var.maxRetries }
        M118 P0 L2 S{"Connection " ^ var.connIndex ^ " is unresponsive, rebooting!"}
        M999
    M118 P0 L2 S{"Waiting for connection " ^ var.connIndex ^ " to enter state " ^ param.S}
    G4 P{var.waitTime * 100 } ; We specify wait time as milliseconds so this is "waitTime / 10 * 1000"
    set var.retries = var.retries + 1
