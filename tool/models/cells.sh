#!/usr/bin/env bash
# Renders models of godot/assets/models/ side by side on the cells of a map, as
# the game's map camera shows them: to judge the scale of what stands on the
# cells and how they tell apart.
#   tool/models/cells.sh <name>[,<name>...] [out prefix]
# writes <out prefix>_near.png (a few cells across) and <out prefix>_far.png (a
# phone's width of the map, as the player sees it; the prefix defaults to
# /tmp/models_preview/cells). A name may end in @rrggbb to tint the model's node
# Tint (map_faille@69f0ae) and in ! to dim it as an emptied content (map_wreck!).
# board.sh adds these two views to its board with CELLS=1. Never write the
# renders in the repo. GODOT names the engine binary.
set -euo pipefail
cd "$(dirname "$0")/../.."
list="${1:?usage: tool/models/cells.sh <name>[,<name>...] [out prefix]}"
prefix="${2:-/tmp/models_preview/cells}"
prefix="${prefix%.png}"
[[ $prefix == /* ]] || prefix="$PWD/$prefix"
IFS=, read -ra names <<< "$list"
for name in "${names[@]}"; do
  base="${name%%[@!]*}"
  [[ -f godot/assets/models/$base.glb ]] || { echo "No model godot/assets/models/$base.glb" >&2; exit 1; }
done
mkdir -p "$(dirname "$prefix")"
rm -f "${prefix}"_{near,far}.png
godot="${GODOT:-godot}"
"$godot" --headless --path godot --import > /dev/null 2>&1
xvfb-run -a -s "-screen 0 1920x1080x24" "$godot" --path godot --audio-driver Dummy \
  --rendering-method gl_compatibility --rendering-driver opengl3 \
  --script res://tool/models/cells.gd -- "$prefix" "${names[@]}" 2>&1 \
  | grep -E "\.png$|ERROR|error" || true
[[ -f ${prefix}_far.png ]] || { echo "The cells did not render." >&2; exit 1; }
