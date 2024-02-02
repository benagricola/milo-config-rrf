; logging.g
; Rotate log files, overwriting existing files
; As we rotate in order (high to low) we should only ever
; delete the last log file.

var rotatedFiles = { global.logFileNum }
while { var.rotatedFiles > 0 }
    var sourceFile = { global.logFilePath ^ "/" ^ global.logFileName ^ (var.rotatedFiles - 1 > 0 ? "." ^ (var.rotatedFiles-1) : "") }
    var targetFile = { global.logFilePath ^ "/" ^ global.logFileName ^ "." ^ var.rotatedFiles }

    ; Query the object model for the source file's information
    M409 K{ "volumes[0].files[" ^ sourceFile ^ "]" }

    ; Check if the source file exists
    if { result != null }
        ; If the source file exists, rotate it
        M471 D1 S{var.sourceFile} T{var.targetFile}
    else
        ; If the source file does not exist, print a message to the console
        echo { "Source file does not exist: " ^ var.sourceFile }

    set var.rotatedFiles = { var.rotatedFiles - 1 }

; Enable Logging
M929 P{global.logFilePath ^ "/" ^ global.logFileName} S2