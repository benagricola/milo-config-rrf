# Millennium Milo V1.5 Gcode Flavour

# `G27`   - PARK
Parking is used widely throughout probing and tool changing to move the spindle and work area to safe, easily accessible locations. CNC Firmwares do not always provide a generic park function (including RRF) so we implement our own.

# `G37`   - PROBE TOOL LENGTH
When using multiple milling tools, we must compensate for length differences between the tools. G37 can be used to (re-)calculate the length of the current tool in relation to a reference surface.

# `G6000` - CUBOID WORKPIECE PROBING
Walks the user through probing Z and X / Y dimensions of a cuboid workpiece, and allows the user to select between 5 different work zero points - Front Left, Front Right, Back Left, Back Right and Centre.

# `G6001` - `G6004` - PROBE IN DIRECTION
These should not be used directly, they are called by tool change and probing macros to execute individual probes.

# `G7000` - ENABLE HSSC
Enables harmonic spindle speed control. When the spindle is active, this adjusts the RPM of the spindle up and down by a given value over a given period to avoid harmonics between the spindle and the workpiece.

# `G7001` - DISABLE HSSC
Turns off harmonic spindle speed control and if spindle is active, resets the RPM to the base RPM that adjustments were being executed on.

# `T<N>`  - CHANGE NEXT TOOL INDEX
Since the Milo is a single spindle mill and will almost certainly require manual tool-changes, the `T<N>` gcode is of limited use on its' own to select tools - as the only identifier passed to it is the tool number. 

In an industrial environment with a standardized job setup sheet this wouldn't be a problem, but many Milo users are machining novices, and we want to open up multi-tool workflows to these users with the smallest amount of friction possible.

For that reason, we do _not_ perform any physical actions when `T<N>` is called, but we do track the tool number given as the "next" tool, as this is used later in the tool changing process.

# `M6`   - CHANGE TOOL
In combination with `T<N>`, M6 triggers the manual tool-changing process. In RRF we use a custom M6 macro as `M6` is not defined by default, and this allows us to pass an optional custom parameter, `S"<description of tool>"`. The user is prompted through RRF's Duet Web Control (DWC) interface to change to the correct tool and confirm through clicking a button when the tool is changed.
After the user confirms the tool is changed, the tool length will either be probed using the Tool Setter (if the feature is enabled) or can be measured manually and input by the user.

