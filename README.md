# Station420: Get Dusted

Small Godot 4 example project. Fly a wireframe ship through a starfield, approach orbital stations, and press `E` to dock.

## Open

1. Open Godot.
2. Import `/Users/djcarter/Documents/code/godot/Station420/project.godot`.
3. Run the project.

## Web Export

1. Use the `Web` preset in `Project -> Export`, or run:
   `godot --headless --path /Users/djcarter/Documents/code/godot/Station420 --export-release Web build/web/index.html`
2. Serve the `build/web` folder from a web server.
3. Open `http://127.0.0.1:8000` or your deployed URL in a browser.

For local testing you can serve the exported files with:

`python3 -m http.server 8000 --directory build/web`

## Files

- `project.godot`: project settings and startup scene
- `scenes/main.tscn`: 3D scene, camera, and HUD
- `scripts/main.gd`: starfield, station generation, and docking logic
- `scripts/player.gd`: 3D ship movement and wireframe mesh creation

## Controls

- `W`, `A`, `S`, `D`: move
- `R` and `F`: rise and descend
- `E`: dock when you are close to a station
