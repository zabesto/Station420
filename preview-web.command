#!/bin/zsh
cd "/Users/djcarter/Documents/code/godot/Station420" || exit 1
python3 -m http.server 8000 --directory build/web
