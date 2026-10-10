#!/usr/bin/env bash
# Adds the loading splash (tool/web_splash/) to the web/index.html generated
# by `flutter create`, so the page is never white while the app downloads.
# Run after generate_app_icons.sh: the splash shows web/icons/Icon-*.png.
# Idempotent: running it again replaces the splash instead of duplicating it.
set -euo pipefail

cd "$(dirname "$0")/../.."
dart run tool/web_splash/apply_web_splash.dart
