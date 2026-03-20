# Station420: Get Dusted

Arcade spaceflight prototype in Godot 4.6 with wireframe and shaded render modes, cockpit/chase cameras, procedural radio music, shader presets, and a web export path.

## Open

1. Open Godot 4.6.
2. Import `/Users/djcarter/Documents/code/godot/Station420/project.godot`.
3. Run the project.

Headless validation:

```bash
godot --headless --path /Users/djcarter/Documents/code/godot/Station420 --quit
```

## Web Preview

Re-export and serve the current web build:

```bash
cd /Users/djcarter/Documents/code/godot/Station420
./preview-web.command
```

Then open:

```text
http://127.0.0.1:8000
```

Export only:

```bash
./export-web.command
```

## Main Controls

- `W A S D`: translate ship
- `R / F`: move up / down
- `Q / E`: roll ship
- `Space` or controller `A`: fire
- `E`: dock when in range
- `Tab`: cycle `Orbit / Chase / Cockpit`
- `V`: reset camera view
- `\`: toggle `Wireframe / Shaded`
- `H`: open settings / shader lab
- `J` or controller `D-pad Right`: toggle autopilot
- `T`: toggle trail
- `G`: toggle guidance line
- `B`: toggle bloom
- `P`: toggle `Game / Real` flight mode
- `C`: hail local comms
- `Esc`: pause

## Controller

- Left stick: steer / pitch ship
- Right stick: camera look
- Right trigger: main thrust
- Left trigger: reverse thrust
- `Y`: cycle camera views
- `B`: toggle render mode
- `R3`: reset view
- `D-pad Right`: autopilot
- `D-pad Down`: trail
- `L3`: guidance
- `Back`: settings
- `Start`: pause

## Shader Lab

Open settings with `H` and use the shader dropdown to try:

- `PBR Lite`
- `Neon Edge`
- `Cartoon`
- `Glass`
- `Blur`
- `ASCII`
- `Metal Scan`

The panel exposes:

- `Intensity`
- `Detail`
- `Wire Intensity`
- `Aux Mix`

Visual presets still cycle with keyboard `1-4` or controller `LB / RB`.

## Project Layout

- `scenes/main.tscn`: main scene, HUD, and camera setup
- `scripts/main.gd`: world generation, HUD logic, shaders, audio, AI, autopilot
- `scripts/player.gd`: ship movement, cockpit visuals, thrusters, trail
- `shaders/edge_pass.gdshader`: fullscreen shader lab post-process
- `shaders/attitude_ball.gdshader`: navball / gyro instrument shader
- `shaders/overlay_fog.gdshader`: overlay shader used behind modal screens

## Notes

- Project version is currently `0.4.0-dev`.
- The game includes a checked-in `build/web` export for local preview.
- There is still a shutdown-time Godot warning about leaked `ObjectDB` instances that has not been fully resolved yet.
