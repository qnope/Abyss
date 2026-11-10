#!/usr/bin/env bash
# Renders the game's startup scene for review, as a phone held upright shows
# it (390 x 844 points at 2x), from the views of godot/tool/scene/capture.gd:
#   tool/scene_capture.sh [out dir] [scene]
# writes default.png, rotated.png, close.png and top.png, and prints each
# view's draw calls and primitives. The out dir defaults to
# /tmp/scene_capture: never write the renders in the repo. Godot draws with
# its Compatibility renderer (the web's) in a virtual X display (xvfb-run),
# in software: its frame rate means nothing. GODOT names the engine binary.
set -euo pipefail
cd "$(dirname "$0")/.."
out="${1:-/tmp/scene_capture}"
[[ $out == /* ]] || out="$PWD/$out"
godot="${GODOT:-godot}"
"$godot" --headless --path godot --import > /dev/null 2>&1
xvfb-run -a -s "-screen 0 1280x1800x24" "$godot" --path godot --audio-driver Dummy \
  --rendering-method gl_compatibility --rendering-driver opengl3 --resolution 780x1688 \
  --script res://tool/scene/capture.gd -- "$out" ${2:+"$2"} 2>&1 \
  | grep -vE "^(Godot Engine|OpenGL API|$)" || true
[[ -f $out/default.png ]] || { echo "The scene did not render." >&2; exit 1; }
