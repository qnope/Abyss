#!/usr/bin/env bash
# The floor of a level of the map laid on a grid of cells, in the game's own
# light, camera and water: the tiles of godot/assets/models/map_terrain_<level>.glb
# in their variants, to judge their continuity and look:
#   tool/models/grid.sh <level 1-3> [out prefix]
# writes <out prefix>_grid.png (a board of cells all seen), _gridfog.png (a
# patch seen, the rest under the fog) and _far.png (a 20 x 20 map as the game
# opens it, in the phone's frame). The prefix defaults to
# /tmp/models_preview/map_terrain_<level>: never write the renders in the repo.
# board.sh calls it for the models called map_terrain_<level>. GODOT names the
# engine binary.
set -euo pipefail
cd "$(dirname "$0")/../.."
level="${1:?usage: tool/models/grid.sh <level 1-3> [out prefix]}"
[[ -f godot/assets/models/map_terrain_$level.glb ]] || { echo "No model godot/assets/models/map_terrain_$level.glb" >&2; exit 1; }
prefix="${2:-/tmp/models_preview/map_terrain_$level}"
[[ $prefix == /* ]] || prefix="$PWD/$prefix"
mkdir -p "$(dirname "$prefix")"
godot="${GODOT:-godot}"
"$godot" --headless --path godot --import > /dev/null 2>&1
xvfb-run -a -s "-screen 0 1280x1024x24" "$godot" --path godot --audio-driver Dummy \
  --rendering-method gl_compatibility --rendering-driver opengl3 \
  --script res://tool/models/grid_view.gd -- "$level" "$prefix" 2>&1 \
  | grep -E "\.png$|SCRIPT ERROR|Parse Error" || true
[[ -f ${prefix}_grid.png ]] || { echo "The grid did not render." >&2; exit 1; }
