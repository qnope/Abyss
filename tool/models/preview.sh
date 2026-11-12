#!/usr/bin/env bash
# Renders a model of godot/assets/models/ for review, as the game imports it:
#   tool/models/preview.sh <name>[+<name>...] [out prefix]
# writes <out prefix>_game.png (the game's 3/4 camera), _close (zoomed on its
# front quarter) and _front, _right,
# _back, _left.png, at twice the phone's scale. TIER=n shows the model up to its
# tier n (its nodes Tier1..Tier3 add up) and renders only _game and _close. The prefix defaults to
# /tmp/models_preview/<name>: never write the renders in the repo.
# Godot imports the project, then draws with its Compatibility renderer (the
# web's) in a virtual X display (xvfb-run). GODOT names the engine binary.
set -euo pipefail
cd "$(dirname "$0")/../.."
name="${1:?usage: tool/models/preview.sh <name> [out prefix]}"
name="$(basename "$name" .glb)"
IFS=+ read -ra models <<< "$name"
for model in "${models[@]}"; do
  [[ -f godot/assets/models/$model.glb ]] || { echo "No model godot/assets/models/$model.glb" >&2; exit 1; }
done
prefix="${2:-/tmp/models_preview/$name}"
prefix="${prefix%.png}"
[[ $prefix == /* ]] || prefix="$PWD/$prefix"
mkdir -p "$(dirname "$prefix")"
rm -f "${prefix}"_{game,close,front,right,back,left}.png
godot="${GODOT:-godot}"
"$godot" --headless --path godot --import > /dev/null 2>&1
xvfb-run -a -s "-screen 0 1280x1024x24" "$godot" --path godot --audio-driver Dummy \
  --rendering-method gl_compatibility --rendering-driver opengl3 \
  --script res://tool/models/preview.gd -- "$name" "$prefix" ${TIER:+"$TIER"} 2>&1 \
  | grep -E "\.png$|ERROR|error" || true
[[ -f ${prefix}_game.png ]] || { echo "The preview did not render." >&2; exit 1; }
