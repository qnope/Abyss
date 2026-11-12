#!/usr/bin/env bash
# The review board of a lot of models: one contact sheet, each model in a row
# with its game view, its four sides, its close view and its portrait, its name
# and its budget figures written under it, so that the owner validates a lot
# from one image. A building with tiers (the nodes Tier1..Tier3) has two lines:
# its game views and its close views at tier 1, tiers 1+2 and all tiers, and
# its figures give the cost of each:
#   tool/models/board.sh <name>[,<name>...] <out.png>
# The models are the glb of godot/assets/models/ (tool/models/build.py first).
# It reuses preview.sh and the portrait render, then composes the sheet in
# Godot (board.gd). The intermediate renders go to a temporary folder; write
# the board outside the repo: never commit it. GODOT names the engine binary,
# PYTHON the Python 3.13 with bpy that reads the catalog.
set -euo pipefail
cd "$(dirname "$0")/../.."
list="${1:?usage: tool/models/board.sh <name>[,<name>...] <out.png>}"
out="${2:?usage: tool/models/board.sh <name>[,<name>...] <out.png>}"
[[ $out == /* ]] || out="$PWD/$out"
IFS=, read -ra names <<< "$list"
for name in "${names[@]}"; do
  [[ -f godot/assets/models/$name.glb ]] || { echo "No model godot/assets/models/$name.glb" >&2; exit 1; }
done
godot="${GODOT:-godot}"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
mkdir -p "$(dirname "$out")"
"${PYTHON:-python3}" tool/models/board_figures.py "$work/figures.json" "${names[@]}"
for name in "${names[@]}"; do
  tool/models/preview.sh "$name" "$work/$name" > /dev/null
  # A building with tiers shows its game and close views up to each lower tier.
  tiers="$("${PYTHON:-python3}" -c 'import json,sys; print(next(m["tiers"] for m in json.load(open(sys.argv[1]))["models"] if m["name"] == sys.argv[2]))' "$work/figures.json" "$name")"
  for ((tier = 1; tier < tiers; tier++)); do
    TIER=$tier tool/models/preview.sh "$name" "$work/${name}_t$tier" > /dev/null
  done
done
xvfb-run -a -s "-screen 0 1280x1024x24" "$godot" --path godot --audio-driver Dummy \
  --rendering-method gl_compatibility --rendering-driver opengl3 \
  --script res://tool/models/portrait.gd -- "$work" "${names[@]}" 2>&1 \
  | grep -E "ERROR|error" || true
xvfb-run -a -s "-screen 0 1280x1024x24" "$godot" --path godot --audio-driver Dummy \
  --rendering-method gl_compatibility --rendering-driver opengl3 \
  --script res://tool/models/board.gd -- "$work" "$out" "$work/figures.json" 2>&1 \
  | grep -E "ERROR|error" || true
[[ -f $out ]] || { echo "The board did not render." >&2; exit 1; }
echo "$out"
