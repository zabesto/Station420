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

What `./export-web.command` does:

- Exports the Godot web build into `build/web`.
- Copies that build into `build/cloudflare`.
- Removes the raw `build/cloudflare/index.wasm`.
- Writes `build/cloudflare/index.wasm.gz`.
- Patches the generated Godot loader so Cloudflare serves a static asset bundle without a Worker.
- Updates `build/cloudflare/index.html` so `GODOT_CONFIG.fileSizes` includes `index.wasm.gz`.

## Cloudflare Deploy

Static Cloudflare deployment now works without `worker.js`.

Files involved:

- `wrangler.toml`: points Cloudflare at `build/cloudflare`
- `export-web.command`: prepares both local and Cloudflare web bundles
- `scripts/patch_cloudflare_loader.py`: rewrites the generated Godot loader to request `index.wasm.gz`

Deploy flow:

```bash
cd /Users/djcarter/Documents/code/godot/Station420
./export-web.command
npx wrangler deploy
```

Current production URL:

```text
https://station420.dj-e81.workers.dev
```

Important details:

- `build/web` is the normal local preview output and still uses `index.wasm`.
- `build/cloudflare` is the deployment bundle and uses `index.wasm.gz`.
- The Cloudflare loader reads the wasm response into bytes, detects gzip by signature, inflates it with `DecompressionStream`, and then calls `WebAssembly.instantiate(...)`.
- `_headers` is intentionally removed from `build/cloudflare`; the deploy no longer depends on custom content-encoding headers or a Worker shim.
- `git push` does not deploy this site. Cloudflare only updates when `npx wrangler deploy` is run.

Known validation notes:

- `npx wrangler deploy` successfully published the static bundle on March 19, 2026.
- In this Codex shell, direct requests to `/index.wasm.gz` were intermittently blocked by DNS resolution issues even after a successful deploy, so browser validation should still be done from a normal machine if the site appears stuck on load.
- Godot may print a sandbox warning about saving editor settings under `~/Library/Application Support/Godot/editor_settings-4.6.tres` during headless export. That warning did not block export.

## Phone Controls

- Tap the start screen to launch.
- Left touch pad: thrust and strafe
- Right touch pad: steer and camera look
- `FIRE`: lasers
- `BOOST`: acceleration boost
- `AP`: autopilot
- `CAM`: cycle camera mode
- `DOCK`: dock when in range
- `TGT`: cycle autopilot target
- `UP` / `DN`: vertical thrust

Phone web builds also use:

- `viewport-fit=cover`
- safe-area padding for notches and browser chrome
- larger HUD, settings, shader, and controls panel sizing in portrait mode

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

## Release Flow

Recommended release pass:

```bash
cd /Users/djcarter/Documents/code/godot/Station420
godot --headless --path /Users/djcarter/Documents/code/godot/Station420 --quit
./export-web.command
git status
git push origin main
npx wrangler deploy
```

After deploy, verify from a real browser:

- desktop load
- iPhone portrait load
- tap-to-start
- touch controls
- audio start after interaction

## Project Layout

- `scenes/main.tscn`: main scene, HUD, and camera setup
- `scripts/main.gd`: world generation, HUD logic, shaders, audio, AI, autopilot
- `scripts/player.gd`: ship movement, cockpit visuals, thrusters, trail
- `scripts/ui/attitude_indicator.gd`: 2D attitude / nav indicator widget
- `scripts/ui/tactical_map.gd`: themed tactical map widget
- `shaders/edge_pass.gdshader`: fullscreen shader lab post-process
- `shaders/overlay_fog.gdshader`: overlay shader used behind modal screens

## Notes

- Project version is currently `0.4.0-dev`.
- The game includes a checked-in `build/web` export for local preview.
- The game includes a checked-in `build/cloudflare` export for static Cloudflare deploys.
- There is still a shutdown-time Godot warning about leaked `ObjectDB` instances that has not been fully resolved yet.
