# Millennium Milo V1.5 Gcode Flavour

# `T<N>`
Since the Milo is a single spindle mill and will almost certainly require manual tool-changes, the `T<N>` gcode is of limited use on its' own to select tools - as the only identifier passed to it is the tool number. 

In an industrial environment with a standardized job setup sheet this wouldn't be a problem, but many Milo users are machining novices, and we want to open up multi-tool workflows to these users with the smallest amount of friction possible.

For that reason, we do _not_ perform any physical actions when `T<N>` is called, but we do track the tool number given as the "next" tool, as this is used later in the tool changing process.

# `M6`
In combination with `T<N>`, M6 triggers the manual tool-changing process. In RRF we use a custom M6 macro as `M6` is not defined by default, and this allows us to pass an optional custom parameter, `S"<description of tool>"`. The user is prompted through RRF's Duet Web Control (DWC) interface to change to the correct tool and confirm through clicking a button when the tool is changed.
After the user confirms the tool is changed, the tool length will either be probed using the Tool Setter (if the feature is enabled) or can be measured manually and input by the user.