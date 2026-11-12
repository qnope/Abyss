#!/usr/bin/env bash
# Renders a creature of godot/assets/models/ for review: three poses of each of
# its actions (idle, swim, attack, hit) and how it reads at phone size:
#   tool/models/poses.sh <name> [out prefix]
# writes <out prefix>_<action>_<0|1|2>.png and <out prefix>_phone.png, which the
# board (board.sh) lays out next to the static views. The prefix defaults to
# /tmp/models_preview/<name>: never write the renders in the repo. Godot draws
# with its Compatibility renderer (the web's) in a virtual X display (xvfb-run).
# GODOT names the engine binary.
set -euo pipefail
cd "$(dirname "$0")/../.."
name="$(basename "${1:?usage: tool/models/poses.sh <name> [out prefix]}" .glb)"
[[ -f godot/assets/models/$name.glb ]] || { echo "No model godot/assets/models/$name.glb" >&2; exit 1; }
prefix="${2:-/tmp/models_preview/$name}"
prefix="${prefix%.png}"
[[ $prefix == /* ]] || prefix="$PWD/$prefix"
mkdir -p "$(dirname "$prefix")"
godot="${GODOT:-godot}"
"$godot" --headless --path godot --import > /dev/null 2>&1
xvfb-run -a -s "-screen 0 1280x1024x24" "$godot" --path godot --audio-driver Dummy \
  --rendering-method gl_compatibility --rendering-driver opengl3 \
  --script res://tool/models/poses.gd -- "$name" "$prefix" 2>&1 \
  | grep -E "\.png$|ERROR|error" || true
[[ -f ${prefix}_phone.png ]] || { echo "The poses did not render." >&2; exit 1; }
