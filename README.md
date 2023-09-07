# Millenium Machines Milo RRF Config
Welcome! 

This is a fully featured RepRapFirmware configuration for running the Millenium Machines Milo Desktop CNC Mill. 

This config is open source, and provided as a basis for anyone to use to configure their own machine.

## Use
* Is at your own risk, as outlined in the `LICENSE`. If you break a bit, or cut your hand off, or kill your dog, it's not our fault. *WEAR EYE PROTECTION AND NO, SAFETY SQUINTS ARE NOT IT*.
* Download the zip or .tar.gz of the latest version from the [releases](../../releases/latest) page
* Extract it to the `/sys` folder on your SD card
* Copy the relevant board file for your MCU from the `boards` subdirectory to `/sys/board.txt`
* Configure `user-vars.g` to match your specific setup.
* Place the SD card into your MCU SD card slot and start up the board.
* Use DWC or a serial console to set passwords for WiFi, or to set the AP name if broadcasting its' own AP.
* Reboot the controller (Run `M999`) and wait for it to be accessible on WiFi.
* Test the movement, endstops, relevant macros.
* Do not turn off any of the safety options (safe distances or `global.confirmUnsafeMove`) until you are 100% happy with the behaviour of the code.

## TODO
* DOCUMENT.
* Ability to run the config without the touch probe or toolsetter, by prompting the user manually.
* Add Work Zero detection on surface and hole.
* CNC LCD menu.
* ? Feedback appreciated.

## Macros
This configuration adds some macros to perform work piece touch probing and tool setting.
* `G27` - Stops the spindle and parks it at a safe location (`Z=0`, usually).
  - If `C1` is specified, parks the X/Y area in the middle of its' travel (under the spindle).
  - Otherwise, parks the X/Y area at user-specified co-ordinates.
* `G37` - Performs tool offset calculation, using previously probed reference surface.
* `G6000` - Performs 3 axis work piece probing using the 3D touch probe, running the following steps:
  - Probe the Z height of a reference surface on the X axis. This surface should be a known, static distance from the activation point of the toolsetter, configured in `global.toolSetterHeight`.
  - Allow the operator to move over the work piece surface and probe its Z height multiple times, averaging each result.
  - Ask the operator for a depth at which X and Y edge probing will occur (below the probed Z height of the work piece).
  - Probe the left edge of the work piece at the selected height.
  - Probe the right edge of the work piece at the selected height.
  - Probe the front edge of the work piece at the selected height.
  - Probe the rear edge of the work piece at the selected height.
  - Allow the user to pick the location of the zero point (`FR`, `FL`, `RL`, `RR`, `CTR`. Top surface is `Z=0`) and jog for manual adjustment.
  - Allow the user to pick the WCS index to set the zero on.
* `G6010` - Perform a safe, repeatable probe on the X axis from either the left or right. Called by `G6000`.
* `G6011` - Perform a safe, repeatable probe on the Y axis from either the front or rear. Called by `G6000`.
* `G6012` - Perform a safe, repeatable probe on the Z axis. Can use the toolsetter or the touch probe. Called by `G6000` and `G37`.
* `G6013` - Perform a safe, repeatable probe on the configured reference surface. Called by `G37`.
* `G7000` - Enable Harmonic Spindle Speed Control, which helps to reduce chatter by constantly varying the spindle speed within a range
* `G7001` - Disable Harmonic Spindle Speed Control.

Further information about our macros can be viewed in the [Milo gcode dialect](GCODE.md).
Macros are written following a set of [guidelines](MACROS.md) - if you intend to write additional macros for the Milo, you should follow these guidelines as closely as you can as well.
