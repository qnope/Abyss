#!/usr/bin/env bash
# Runs the tests a few bundles at a time, each bundle one process running
# many test files, far faster than one process per file.
#   tool/test.sh [flutter test options] [test/path ...]
# Paths under test/ choose the files to bundle; anything else goes to
# `flutter test`, as in `tool/test.sh --coverage`.
set -euo pipefail
cd "$(dirname "$0")/.."

paths=()
options=()
for arg in "$@"; do
  case "$arg" in
    test | test/*) paths+=("$arg") ;;
    *) options+=("$arg") ;;
  esac
done

dart run tool/test_bundles.dart ${BUNDLE_SEED:+--seed="$BUNDLE_SEED"} \
  "${paths[@]+"${paths[@]}"}"
flutter test --concurrency=4 "${options[@]+"${options[@]}"}" \
  test/bundles/bundle_*.dart
