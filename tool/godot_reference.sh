#!/usr/bin/env bash
# Replays the games of reference/games/ in Godot and compares every digest
# of every turn with Dart's (godot/tool/replay/README.md).
#   tool/godot_reference.sh [game ...]
# A game is its file name without .json, a long case (a test of whole games
# too long for the unit tests) its name; none plays them all, the longest
# first. Each game runs in a Godot process of its own, GODOT_REFERENCE_JOBS
# at once (the number of cores by default). Prints a line per game and
# exits with 1 when a game differs. GODOT names the engine binary, `godot`
# by default; a game still going after GODOT_TEST_TIMEOUT seconds (600 by
# default) is killed and fails.
set -euo pipefail
cd "$(dirname "$0")/../godot"
godot="${GODOT:-godot}"
seconds="${GODOT_TEST_TIMEOUT:-600}"
limit=()
if command -v timeout > /dev/null; then
  limit=(timeout --kill-after=10 "$seconds")
fi

if [[ ${1:-} == --one ]]; then
  # One game, its output printed at once so that parallel games do not mix.
  status=0
  out=$(${limit[@]+"${limit[@]}"} "$godot" --headless --path . \
    --script res://tool/replay/run_references.gd -- "$2" 2>&1) || status=$?
  grep -v -e '^Godot Engine v' -e '^$' <<< "$out" || true
  if [[ $status -eq 124 || $status -eq 137 ]]; then
    echo "$2: FAILED, not finished within $seconds s (GODOT_TEST_TIMEOUT)"
  elif [[ $status -eq 0 ]] && ! grep -q "^$2: .* ok\$" <<< "$out"; then
    # A script that does not compile leaves Godot idle, and it exits with 0.
    echo "$2: FAILED, the runner did not report it"
    status=1
  fi
  exit $(( status == 0 ? 0 : 1 ))
fi

# As tool/godot_test.sh: refresh the class cache when a script changed.
cache=.godot/global_script_class_cache.cfg
if [[ ! -f $cache ]] || [[ -n $(find . -path ./.godot -prune -o \
  -name '*.gd' -newer "$cache" -print -quit) ]]; then
  if ! log=$(${limit[@]+"${limit[@]}"} "$godot" --headless --path . --import 2>&1); then
    echo "${log:-The import did not finish within $seconds s (GODOT_TEST_TIMEOUT).}" >&2
    exit 1
  fi
  touch "$cache"
fi

games=("$@")
if [[ ${#games[@]} -eq 0 ]]; then
  while IFS= read -r name; do
    games+=("$name")
  done < <("$godot" --headless --path . --script res://tool/replay/run_references.gd -- --list \
    | grep -v '^Godot Engine v')
  if [[ ${#games[@]} -eq 0 ]]; then
    echo "The runner listed no game: does res://tool/replay/run_references.gd compile?" >&2
    exit 1
  fi
fi
jobs="${GODOT_REFERENCE_JOBS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 2)}"
start=$SECONDS
status=0
printf '%s\n' "${games[@]}" | xargs -n 1 -P "$jobs" "../tool/godot_reference.sh" --one || status=$?
echo "${#games[@]} games and cases in $(( SECONDS - start )) s, $jobs at once: $([[ $status -eq 0 ]] && echo ok || echo FAILED)"
exit $(( status == 0 ? 0 : 1 ))
