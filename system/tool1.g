; tool1.g
; Configures attached spindle

; Set minimum and maximum spindle RPM.
; Minimum is achieved at 0% pulse width, Maximum is at 100% pulse width.
; We can achieve higher accuracy with the Aliexpress spindles by treating
; 0% width (and therefore 0v analog input) as our minimum safe spindle speed
; which is usually around 8000rpm. This means our range is ~16000rpm for
; 24000rpm spindles rather than the full 24000rpm which we can't use the lower
; quarter of anyway.
; The VFD must be setup to treat 0v as our minimum spindle speed of 133.33Hz.

M98 P"macros/tool/tool-activate.g" ; Activate tool on start.