# Millenium Machines Milo RRF Config
Welcome! 

This is a fully featured RepRapFirmware configuration for running the Millenium Machines Milo Desktop CNC Mill. 

This config is open source, and provided as a basis for anyone to use to configure their own machine.

## Features
  * Automated hardware-specific configuration for supported MCU's.
  * Easy to use, interactive work piece probing to set your work piece origin.
  * Interactive tool changes, using information from your post-processor.
  * Parking at a user-defined location or centrally.
  * Deactivates and re-activates the Spindle during probing and tool changing.
    - Avoids the spindle being accidentally spun up from the web interface or gcode.
    - Assumes your spindle hardware is connected and configured properly.
  * Variable Spindle Speed Control to avoid chatter from resonance.
    - Varies the spindle RPM up and down within a given range over a given period.


## Use
* Is at your own risk, as outlined in the `LICENSE`. If you break a bit, or cut your hand off, or kill your dog, it's not our fault. *WEAR EYE PROTECTION AND NO, SAFETY SQUINTS ARE NOT IT*.
* Use the [configurator](https://benagricola.github.io/milo-config-rrf/) to generate a zip file containing the firmware configuration for your machine.
* Extract the zip onto your SD card (at the root, /).
* Place the SD card into your MCU SD card slot and start up the board.
* Test the movement, endstops, relevant macros.
* Do not turn off any of the safety options (safe distances or `global.confirmUnsafeMove`) until you are 100% happy with the behaviour of the code.

## Post Processors
Compatible post-processors are available in the `post-processors` directory. They assume that safety checks are implemented by the firmware, so you _should not_ use these with any other RRF firmware configuration!


## TODO
* DOCUMENT.
* Ability to run the config without the touch probe or toolsetter, by prompting the user manually.
* Add Work Zero detection on surface and hole.
* ? Feedback appreciated.

## Macros
  See [gcode](./GCODE.md)

## Learn or Contribute
Further information about our macros can be viewed in the [Milo gcode dialect](GCODE.md).
Macros are written following a set of [guidelines](MACROS.md) - if you intend to write additional macros for the Milo, you should follow these guidelines as closely as you can as well.
