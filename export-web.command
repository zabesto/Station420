#!/bin/zsh

set -euo pipefail

PROJECT_DIR="/Users/djcarter/Documents/code/godot/Station420"
EXPORT_DIR="$PROJECT_DIR/build/web"
CF_DIR="$PROJECT_DIR/build/cloudflare"

mkdir -p "$EXPORT_DIR"
mkdir -p "$CF_DIR"

cd "$PROJECT_DIR"
godot --headless --path "$PROJECT_DIR" --export-debug Web "$EXPORT_DIR/index.html"

rm -rf "$CF_DIR"
mkdir -p "$CF_DIR"
cp -R "$EXPORT_DIR/." "$CF_DIR/"
rm -f "$CF_DIR/.DS_Store"
find "$CF_DIR" -name "*.import" -delete
rm -f "$CF_DIR/index.wasm"
gzip -c "$EXPORT_DIR/index.wasm" > "$CF_DIR/index.wasm.gz"
cat > "$CF_DIR/_headers" <<'EOF'
/index.wasm.gz
  Content-Encoding: gzip
  Content-Type: application/wasm
EOF

echo "Web export updated at $EXPORT_DIR"
echo "Cloudflare assets prepared at $CF_DIR"
