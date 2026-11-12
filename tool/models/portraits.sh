#!/usr/bin/env bash
# Renders the portraits of the models for the interface, as the game imports
# them: a fixed 3/4 camera, the studio light, a transparent background, 256 px
# square, written to godot/assets/portraits/<name>.png (committed, like the
# glb: never edited by hand, regenerate them with this command):
#   tool/models/portraits.sh [name ...]
# Without a name, every model that declares PORTRAIT = True in its script.
# Godot imports the project, then draws with its Compatibility renderer (the
# web's) in a virtual X display (xvfb-run); GODOT names the engine binary,
# PYTHON the Python 3.13 with bpy that reads the catalog.
set -euo pipefail
cd "$(dirname "$0")/../.."
godot="${GODOT:-godot}"
mapfile -t names < <("${PYTHON:-python3}" tool/models/portraits.py "$@")
(( ${#names[@]} )) || { echo "No model declares a portrait." >&2; exit 1; }
out="$PWD/godot/assets/portraits"
mkdir -p "$out"
"$godot" --headless --path godot --import > /dev/null 2>&1
xvfb-run -a -s "-screen 0 1280x1024x24" "$godot" --path godot --audio-driver Dummy \
  --rendering-method gl_compatibility --rendering-driver opengl3 \
  --script res://tool/models/portrait.gd -- "$out" "${names[@]}" 2>&1 \
  | grep -E "\.png$|ERROR|error" || true
for name in "${names[@]}"; do
  [[ -f $out/$name.png ]] || { echo "The portrait of $name did not render." >&2; exit 1; }
done
# Shown at half its size or less, a portrait wants its mipmaps.
"$godot" --headless --path godot --import > /dev/null 2>&1
for name in "${names[@]}"; do
  sed -i 's|^mipmaps/generate=false|mipmaps/generate=true|' "$out/$name.png.import"
done
"$godot" --headless --path godot --import > /dev/null 2>&1
