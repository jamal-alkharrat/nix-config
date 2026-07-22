#!/usr/bin/env bash
# App switcher with dynamic capture — called from Karabiner shell_command.
#   app-switcher.sh N           → open app bound to slot N
#   app-switcher.sh N --capture → capture frontmost app into slot N
#   app-switcher.sh --reset     → clear all captured overrides

set -euo pipefail

CACHE="$HOME/.cache/app-switcher"
mkdir -p "$CACHE"

declare -A DEFAULTS=(
  [1]="Safari"
  [2]="Visual Studio Code"
  [3]="Ghostty"
  [4]="Finder"
  [5]="Spotify"
  [6]="System Settings"
  [7]="WhatsApp"
  [8]="Passwords"
  [9]="Obsidian"
  [0]="Notion"
)

notify() { osascript -e "display notification \"$1\" with title \"App Switcher\"" 2>/dev/null || true; }

frontmost_app() {
  osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true'
}

case "${1:-}" in
  --reset)
    rm -f "$CACHE"/*
    notify "All shortcuts reset to defaults"
    ;;
  *)
    KEY="${1:-}"
    ACTION="${2:---open}"

    if [ -z "$KEY" ]; then
      echo "Usage: app-switcher <key> [--capture]" >&2
      exit 1
    fi

    case "$ACTION" in
      --capture)
        APP="$(frontmost_app)"
        echo "$APP" > "$CACHE/$KEY"
        notify "⌥$KEY → $APP"
        ;;
      --open)
        if [ -f "$CACHE/$KEY" ]; then
          open -a "$(cat "$CACHE/$KEY")"
        else
          open -a "${DEFAULTS[$KEY]:-${DEFAULTS[$KEY]}}"
        fi
        ;;
    esac
    ;;
esac
