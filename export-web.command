#!/bin/zsh

set -euo pipefail

PROJECT_DIR="/Users/djcarter/Documents/code/godot/Station420"
EXPORT_DIR="$PROJECT_DIR/build/web"

mkdir -p "$EXPORT_DIR"

cd "$PROJECT_DIR"
godot --headless --path "$PROJECT_DIR" --export-debug Web "$EXPORT_DIR/index.html"

echo "Web export updated at $EXPORT_DIR"
