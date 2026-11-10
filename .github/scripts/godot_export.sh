#!/usr/bin/env bash
# Exports the Godot project (godot/) with one of its export presets.
#   .github/scripts/godot_export.sh <preset> <output path, relative to godot/>
# Imports the project first, and once more if that import fails: Godot once
# crashed while importing a font. Run after install_godot.sh with the
# preset's platform templates.
set -euo pipefail

preset=${1:?usage: godot_export.sh <preset> <output>}
output=${2:?usage: godot_export.sh <preset> <output>}
cd "$(dirname "$0")/../../godot"
if ! godot --headless --path . --import; then
  echo "The import failed: trying once more." >&2
  godot --headless --path . --import
fi
mkdir -p "$(dirname "$output")"
godot --headless --path . --export-release "$preset" "$output"
