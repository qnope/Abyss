#!/usr/bin/env bash
# Runs the Godot tests headless, every test file in one process.
#   tool/godot_test.sh [test file or folder ...]
# Paths are res://, relative to godot/, or relative to the repo root
# (godot/app); none runs every *_test.gd. Exits with 1 when a test fails.
# GODOT names the engine binary, `godot` by default.
set -euo pipefail
cd "$(dirname "$0")/../godot"
godot="${GODOT:-godot}"

# A --script run finds class_name scripts through the editor's cache, which
# only an import writes: refresh it when a script is newer than the cache.
cache=.godot/global_script_class_cache.cfg
if [[ ! -f $cache ]] || [[ -n $(find . -path ./.godot -prune -o \
  -name '*.gd' -newer "$cache" -print -quit) ]]; then
  if ! log=$("$godot" --headless --path . --import 2>&1); then
    echo "$log" >&2
    exit 1
  fi
  touch "$cache"
fi

paths=()
for arg in "$@"; do
  paths+=("${arg#godot/}")
done
exec "$godot" --headless --path . --script res://tool/test/run_tests.gd \
  -- "${paths[@]+"${paths[@]}"}"
