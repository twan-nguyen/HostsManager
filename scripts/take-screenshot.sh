#!/usr/bin/env bash
# Capture a screenshot of the Devly app window for README.
#
# Usage:
#   scripts/take-screenshot.sh <name>
#
# Then click on the Devly window to capture. Output saved to
# design/screenshots/<name>.png.
#
# Suggested names: 01-hosts, 02-env, 03-command-palette, 04-menubar.

set -euo pipefail

NAME="${1:-screenshot}"
OUT_DIR="design/screenshots"
mkdir -p "$OUT_DIR"

OUT="$OUT_DIR/${NAME}.png"

echo "→ Click vào cửa sổ Devly (cần activate trước)"
osascript -e 'tell application "Devly" to activate' 2>/dev/null || true
sleep 0.5

screencapture -W -o "$OUT"

if [ -f "$OUT" ]; then
  echo "✓ Saved: $OUT ($(du -h "$OUT" | cut -f1))"
else
  echo "✗ Capture cancelled"
  exit 1
fi
