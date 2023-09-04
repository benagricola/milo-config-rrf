; config.g: Load modular configuration for Milo CNC Mill


; DO NOT EDIT. All user configuration can be made in user-vars.g
M98 P"mcu.g" ; Load mcu and static configuration first to allow user overrides
M98 P"vars.g"
M98 P"user-vars.g"
M98 P"leds.g"
M98 P"general.g"
M98 P"estop.g"
M98 P"logging.g"
M98 P"drives.g"
M98 P"speed.g"
M98 P"limits.g"
M98 P"toolsetter.g"
M98 P"touchprobe.g"
M98 P"fans.g"
M98 P"tool1.g"
M98 P"network.g"
M98 P"screen.g"