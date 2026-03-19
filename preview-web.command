#!/bin/zsh
cd "/Users/djcarter/Documents/code/godot/Station420" || exit 1
pkill -f "http.server 8000" 2>/dev/null || true
pkill -f "serve-web.py" 2>/dev/null || true
./export-web.command || exit 1
python3 ./serve-web.py
