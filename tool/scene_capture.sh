#!/usr/bin/env bash
# Renders the 3D prototype, the app's screens and the UI kit for review, as a
# phone held upright shows them (390 x 844 points at 2x):
#   tool/scene_capture.sh [out dir] [scene | app | kit]
# With no scene, it writes default.png, rotated.png, close.png and top.png from
# the views of godot/tool/scene/capture.gd, then app_menu_empty.png,
# app_menu.png, app_new_game.png, app_saves.png, app_story.png and app_game.png
# from godot/tool/scene/app_capture.gd, then kit_a.png, kit_b.png, kit_b_en.png,
# kit_dialog.png, kit_sheet.png and kit_page.png from
# godot/tool/scene/kit_capture.gd, and prints each view's draw calls and
# primitives. With a scene (res://...tscn) only the first, on that scene; with
# `app` only the second; with `kit` only the third. The out dir defaults to
# /tmp/scene_capture: never write the renders in the repo. Godot draws with
# its Compatibility renderer (the web's) in a virtual X display (xvfb-run), in
# software: its frame rate means nothing. GODOT names the engine binary.
set -euo pipefail
cd "$(dirname "$0")/.."
out="${1:-/tmp/scene_capture}"
[[ $out == /* ]] || out="$PWD/$out"
which="${2:-}"
godot="${GODOT:-godot}"
"$godot" --headless --path godot --import > /dev/null 2>&1

# capture <script> [scene]: runs a capture script in the virtual display, and
# stops it after GODOT_CAPTURE_TIMEOUT seconds (120 by default).
limit=()
if command -v timeout > /dev/null; then
  limit=(timeout --kill-after=10 "${GODOT_CAPTURE_TIMEOUT:-120}")
fi
capture() {
  ${limit[@]+"${limit[@]}"} xvfb-run -a -s "-screen 0 1280x1800x24" "$godot" --path godot --audio-driver Dummy \
    --rendering-method gl_compatibility --rendering-driver opengl3 --resolution 780x1688 \
    --script "$1" -- "$out" ${2:+"$2"} 2>&1 | grep -vE "^(Godot Engine|OpenGL API|$)" || true
}

if [[ $which != kit && $which != app ]]; then
  capture res://tool/scene/capture.gd "$which"
  [[ -f $out/default.png ]] || { echo "The scene did not render." >&2; exit 1; }
fi
if [[ -z $which || $which == app ]]; then
  capture res://tool/scene/app_capture.gd
  [[ -f $out/app_game.png ]] || { echo "The app did not render." >&2; exit 1; }
fi
if [[ -z $which || $which == kit ]]; then
  capture res://tool/scene/kit_capture.gd
  [[ -f $out/kit_page.png ]] || { echo "The UI kit did not render." >&2; exit 1; }
fi
