; M7000.g
; Enable and configure Harmonic Spindle Speed Control
;
; USAGE: "M7000 P<period-in-ms> V<variance>"


if { !exists(param.P) }
    abort { "Must specify period (P..) in milliseconds between spindle speed adjustments" }

if { !exists(param.V) }
    abort { "Must specify variance (V..) in rpm of spindle speed adjustments" }

if { param.P < global.daemonUpdateRate }
    abort { "Period cannot be less than daemonUpdateRate (" ^ global.daemonUpdateRate ^ "ms)" }

if { mod(param.P, global.daemonUpdateRate) > 0 }
    abort { "Period must be a multiple of daemonUpdateRate (" ^ global.daemonUpdateRate ^ ")ms" }

set global.hsscPeriod             = param.P
set global.hsscVariance           = param.V
set global.hsscEnabled            = true
set global.hsscSpeedWarningIssued = false

if { global.hsscDebug }
    M118 P0 L2 S{"[HSSC] State: Enabled Period: " ^ param.P ^ "ms Variance: " ^ param.V ^ "RPM" }