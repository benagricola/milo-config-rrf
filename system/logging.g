; Rotate log files, overwriting existing files
; As we rotate in order (high to low) we should only ever
; delete the last log file.
var rotatedFiles = global.logFileNum
while var.rotatedFiles > 0
    if var.rotatedFiles - 1 = 0
        M471 D1 S{global.logFilePath ^ "/" ^ global.logFileName} T{global.logFilePath ^ "/" ^ global.logFileName ^ "." ^ var.rotatedFiles}
    else
        M471 D1 S{global.logFilePath ^ "/" ^ global.logFileName ^ "." ^ var.rotatedFiles-1} T{global.logFilePath ^ "/" ^ global.logFileName ^ "." ^ var.rotatedFiles}
    set var.rotatedFiles = var.rotatedFiles - 1

; Enable Logging
M929 P{global.logFilePath ^ "/" ^ global.logFileName} S2