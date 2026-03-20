# Shader Catalog

This project currently has three active shader sources and several runtime visual modes built on top of them.

Use this file as the practical list of effects you can experiment with in-game.

## Where To Try Them

- `FX` button: shader-specific controls and the fullscreen screen-mode browser
- `⚙` button: game settings, theme, audio, flight, render mode, bloom
- `INS` button: object inspector, solo/trippy override, global pass toggles

## Shader Files

These are the actual shader source files currently present in `shaders/`.

### `shaders/edge_pass.gdshader`

Type:
- fullscreen `canvas_item` post-process

Used for:
- the main screen-space look applied over the rendered scene

Parameters exposed in-game:
- `Shader` mode dropdown
- `Intensity`
- `Detail`
- `Glow`
- `Wire Intensity`
- `Aux Mix`
- `Screen FX` on/off

Available screen modes:
- `PBR Lite`
- `Neon Edge`
- `Cartoon`
- `Glass`
- `Blur`
- `ASCII`
- `Metal Scan`
- `CRT Grid`
- `Night Vision`
- `Thermal`
- `Blueprint`

Notes:
- This is the main shader-browser surface in the current build.
- Most “try a new effect live” work should start here.

### `shaders/overlay_fog.gdshader`

Type:
- fullscreen `canvas_item` overlay pass

Used for:
- modal/background blur
- HUD atmosphere / fog tint

Parameters exposed in-game:
- `Overlay Blur` on/off
- indirect tuning through `Aux Mix`

Notes:
- This is not a separate mode browser like `edge_pass.gdshader`.
- It works as a supporting layer behind panels and transitions.

### `shaders/trippy_surface.gdshader`

Type:
- `spatial` material shader

Used for:
- the `Trippy Prism` preset
- per-object trippy override from the inspector

How to try it:
- choose the `Trippy Prism` theme/preset
- or pick an object with `INS` and use `Trippy`

Notes:
- This is the main object-level experimental shader in the project.
- It affects ships, stations, and other styled scene meshes rather than the whole screen.

## Runtime Theme / Preset Layer

These are not separate shader files, but they are real visual looks you can apply in-game.

Available presets:
- `Deep Space`
- `Neon Wireframe`
- `Toon Combat`
- `Hologram Drift`
- `Cobalt Neon`
- `Trippy Prism`
- `Violet Pulse`

What they change:
- HUD colors
- wireframe material colors
- shaded material colors
- edge-pass tinting
- blur tinting
- some emissive and world styling choices

## Inspector Overrides

The visual inspector exposes runtime overrides that are useful for testing:

- `Screen FX`
- `Blur`
- `Bloom`
- `Solo`
- `Trippy`
- `Reset`

These are not all unique shader files, but they are part of the practical visual stack you can toggle while comparing looks.

## Current Practical Stack

When you are looking at something in-game, the visible result usually comes from this stack:

1. object material or object shader
2. preset/theme tinting
3. fullscreen `edge_pass.gdshader`
4. fullscreen `overlay_fog.gdshader`
5. HUD/theme overlays

So the project does not have a huge library of many standalone shader files yet. It has:

- one main fullscreen post shader
- one overlay shader
- one object-level experimental shader
- several preset combinations and runtime modes built on top of those

## Not Active

There are no extra inactive `.gdshader` source files sitting in the repo right now.

The only leftover shader-related artifact is:

- `shaders/attitude_ball.gdshader.uid`

What that means:
- this is a Godot metadata sidecar, not a usable shader source
- the old attitude-ball shader source file is gone
- the live attitude indicator is now a 2D widget, so that old shader path is not available to use

So the practical split is:

- active shader source files:
  - `shaders/edge_pass.gdshader`
  - `shaders/overlay_fog.gdshader`
  - `shaders/trippy_surface.gdshader`
- inactive shader artifact:
  - `shaders/attitude_ball.gdshader.uid`
