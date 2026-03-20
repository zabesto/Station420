#!/bin/zsh

set -euo pipefail

PROJECT_DIR="/Users/djcarter/Documents/code/godot/Station420"
EXPORT_DIR="$PROJECT_DIR/build/web"
CF_DIR="$PROJECT_DIR/build/cloudflare"

mkdir -p "$EXPORT_DIR"
mkdir -p "$CF_DIR"

cd "$PROJECT_DIR"
godot --headless --path "$PROJECT_DIR" --export-debug Web "$EXPORT_DIR/index.html"
python3 "$PROJECT_DIR/scripts/patch_web_shell.py" "$EXPORT_DIR/index.html"

rm -rf "$CF_DIR"
mkdir -p "$CF_DIR"
cp -R "$EXPORT_DIR/." "$CF_DIR/"
rm -f "$CF_DIR/.DS_Store"
find "$CF_DIR" -name "*.import" -delete
rm -f "$CF_DIR/index.wasm"
gzip -c "$EXPORT_DIR/index.wasm" > "$CF_DIR/index.wasm.gz"
python3 "$PROJECT_DIR/scripts/patch_cloudflare_loader.py" "$CF_DIR"
python3 "$PROJECT_DIR/scripts/patch_web_shell.py" "$CF_DIR/index.html"
rm -f "$CF_DIR/_headers"

echo "Web export updated at $EXPORT_DIR"
echo "Cloudflare assets prepared at $CF_DIR"
