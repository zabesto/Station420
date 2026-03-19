#!/bin/zsh

set -euo pipefail

PROJECT_DIR="/Users/djcarter/Documents/code/godot/Station420"
WATCH_PATHS=(
  "$PROJECT_DIR/scripts"
  "$PROJECT_DIR/scenes"
  "$PROJECT_DIR/project.godot"
)
GAME_PATTERN="godot.*Station420"
POLL_SECONDS=1

if ! command -v fswatch >/dev/null 2>&1; then
  echo "fswatch is required for dev-restart.sh"
  echo "Install it with: brew install fswatch"
  exit 1
fi

start_game() {
  if pgrep -f "$GAME_PATTERN" >/dev/null 2>&1; then
    return
  fi
  open -a Godot --args --path "$PROJECT_DIR"
}

stop_game() {
  pkill -f "$GAME_PATTERN" 2>/dev/null || true
  while pgrep -f "$GAME_PATTERN" >/dev/null 2>&1; do
    sleep 0.2
  done
}

restart_game() {
  stop_game
  sleep 0.3
  start_game
}

echo "Watching Station420 for changes and relaunching on quit..."
echo "Press Ctrl+C to stop."

start_game

fswatch -0 "${WATCH_PATHS[@]}" | while IFS= read -r -d '' _event; do
  echo "Change detected, restarting Godot..."
  restart_game
done &
WATCHER_PID=$!

cleanup() {
  kill "$WATCHER_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

while true; do
  if ! pgrep -f "$GAME_PATTERN" >/dev/null 2>&1; then
    echo "Godot is not running, relaunching..."
    start_game
  fi
  sleep "$POLL_SECONDS"
done
