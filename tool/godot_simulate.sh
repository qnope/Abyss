#!/usr/bin/env bash
# Plays scripted games headless with the Godot port of the rules, as
# `dart run bin/simulate.dart` does with the Dart ones, and prints the very
# same text (godot/tool/simulate/README.md).
#   tool/godot_simulate.sh --strategy balanced --games 100
#   tool/godot_simulate.sh --replay scenarios/replays/victoire-tour-85.json --new-map --json
# The options are those of bin/simulate.dart; --workers is read and left
# out. --scenario and --replay are read from the current folder. GODOT names
# the engine binary, `godot` by default. Exits with 1 where Dart throws.
set -euo pipefail
here="$(cd "$(dirname "$0")/.." && pwd)"
godot="${GODOT:-godot}"

# As tool/godot_test.sh: refresh the class cache when a script changed.
cache="$here/godot/.godot/global_script_class_cache.cfg"
if [[ ! -f $cache ]] || [[ -n $(find "$here/godot" -path "$here/godot/.godot" -prune -o \
  -name '*.gd' -newer "$cache" -print -quit) ]]; then
  if ! log=$("$godot" --headless --path "$here/godot" --import 2>&1); then
    echo "$log" >&2
    exit 1
  fi
  touch "$cache"
fi

out="$(mktemp)"
trap 'rm -f "$out"' EXIT
status=0
ABYSS_CWD="$PWD" ABYSS_SIMULATE_OUT="$out" "$godot" --headless --path "$here/godot" \
  --script res://tool/simulate/simulate.gd -- "$@" > /dev/null || status=$?
if [[ $status -eq 0 && ! -s $out ]]; then
  # A script that does not compile leaves Godot idle, and it exits with 0.
  echo "The simulator printed nothing: does res://tool/simulate/simulate.gd compile?" >&2
  exit 1
fi
cat "$out"
exit $(( status == 0 ? 0 : 1 ))
