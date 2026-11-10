#!/usr/bin/env bash
# Installs the Godot of godot/GODOT_VERSION in a Linux dev container, with the
# export templates of the web, Android and iOS exports only (none of the
# desktop, threaded web or GDExtension ones), and links `godot` into
# /usr/local/bin. Idempotent: what is installed is not downloaded again, and
# the downloaded archives are removed. GODOT_INSTALL_DIR is where the editor
# goes, $HOME/godot by default.
#   tool/install_godot_dev.sh
set -euo pipefail
cd "$(dirname "$0")/.."

binary=$(GODOT_INSTALL_DIR="${GODOT_INSTALL_DIR:-$HOME/godot}" \
  .github/scripts/install_godot.sh "$(cat godot/GODOT_VERSION)" web android ios | tail -n 1)
link=/usr/local/bin/godot
if [[ $(readlink "$link" 2> /dev/null) != "$binary" ]]; then
  if [[ -w $(dirname "$link") ]]; then
    ln -sfn "$binary" "$link"
  else
    sudo ln -sfn "$binary" "$link"
  fi
fi
echo "$link -> $binary ($(godot --version))"
