# Millenium Machines Milo v1.5 RRF Config
Welcome! This is the configuration running on my Milo v1.5, Serial `M016`.

This config is open source, and provided as a basis for anyone to use to configure their own machine.

## Notes

1. `M016` is running the FMJ mod, which means it has 120mm of Z travel.
2. It uses a NEGATIVE Z, which means the endstop at the top of the Z axis is Z=0, and the bottom of the travel is -120mm.
3. It has a Fysetc 128x64 screen mounted in the front, which is used to report machine status using the included Neopixel colours.
4. The Neopixels invert Red and Green for some reason, so this config assumes that `U` and `R` in `M150` calls are inverted.
5. The screen itself is currently not used, as there are no CNC menu packs available (TBD).
6. All operator-configurable options are in `user-vars.g` except for the machine name, which is in `config.g`.
7. `M016` has the Long John Toolsetter which is an official mod for the Milo.
8. `M016` has an Aliexpress "3d Touch Probe Edge Finder" which is a NORMALLY OPEN setup. This means the operator must manually confirm the probe is working BEFORE PROBING.
9. `M016` uses a Fysetc Spider King board. As such, it needs at least TeamGloomy RRF 3.5-beta4, as this contains SPI fixes for the BIG5160 driver slots on the board.

_REMEMBER_: If you are not using a Spider King and the exact driver setup I am, you will need to modify your `board.txt` and motor configs (`drive.g`) which are not currently deemed "operator configurable".

## Macros
This configuration adds some macros to perform work piece touch probing and tool setting.
* `G27` - Stops the spindle and parks it at a safe location (Z=0, usually).
  - If `C1` is specified, parks the X/Y area in the middle of its' travel (under the spindle).
  - Otherwise, parks the X/Y area at user-specified co-ordinates.
* `G37` - Performs tool offset calculation, using previously probed reference surface. Must be run _after_ `G6000`. Sets the offset on the current tool.
* `G6000` - Performs 3 axis work piece probing using the 3d touch probe, running the following steps:
  - Probe the Z height of a reference surface on the X axis. This surface should be a known, static distance from the activation point of the toolsetter, configured in `global.toolSetterHeight`.
  - Allow the operator to move over the work piece surface and probe its Z height multiple times, averaging each result.
  - Ask the operator for a depth at which X and Y edge probing will occur (below the probed Z height of the work piece).
  - Probe the left edge of the work piece at the selected height
  - Probe the right edge of the work piece at the selected height
  - Probe the front edge of the work piece at the selected height
  - Probe the rear edge of the work piece at the selected height
  - Allow the user to pick the location of the zero point (FR, FL, RL, RR, CTR. Top surface is Z=0) and jog for manual adjustment
  - Allow the user to pick the WCS index to set the zero on.
* `G6001` - Perform a safe, repeatable probe on the X axis from either the left or right. Called by `G6000`.
* `G6002` - Perform a safe, repeatable probe on the Y axis from either the front or rear. Called by `G6000`.
* `G6003` - Perform a safe, repeatable probe on the Z axis. Can use the toolsetter or the touch probe. Called by `G6000` and `G37`.
