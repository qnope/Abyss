#!/usr/bin/env bash
# Installs a pinned Godot editor, and the export templates of the given
# platforms, each download checked against the SHA-512 pinned in
# godot_sha512sums.txt beside this script.
#   .github/scripts/install_godot.sh <version> [web|android|ios ...]
# <version> is as in godot/GODOT_VERSION (4.7.2-stable). The editor goes to
# GODOT_INSTALL_DIR ($HOME/.local/godot/<version> by default) with a `godot`
# command in its bin/ folder, added to $GITHUB_PATH on GitHub Actions. The
# templates go where the editor looks for them. The last line printed is the
# engine binary's path. Linux x86_64 and macOS. Idempotent: what is already
# installed is not downloaded again, and the archives go to a temporary
# folder removed on exit.
set -euo pipefail

version=${1:?usage: install_godot.sh <version> [web|android|ios ...]}
shift
sums="$(cd "$(dirname "$0")" && pwd)/godot_sha512sums.txt"
dir=${GODOT_INSTALL_DIR:-$HOME/.local/godot/$version}
release=${version%-*}
flavor=${version##*-}
case "$(uname -s)" in
  Linux)
    slug=linux.x86_64.zip platform=linux.64
    binary="$dir/Godot_v${version}_linux.x86_64"
    templates="${XDG_DATA_HOME:-$HOME/.local/share}/godot/export_templates/$release.$flavor" ;;
  Darwin)
    slug=macos.universal.zip platform=macos.universal
    binary="$dir/Godot.app/Contents/MacOS/Godot"
    templates="$HOME/Library/Application Support/Godot/export_templates/$release.$flavor" ;;
  *) echo "install_godot.sh: no Godot editor for $(uname -s)" >&2; exit 1 ;;
esac

# The template files each platform's export reads; the web export is the
# single-threaded one, the Android one uses the prebuilt APKs, not Gradle.
files=(version.txt)
for target in "$@"; do
  case "$target" in
    web) files+=(web_nothreads_release.zip web_nothreads_debug.zip) ;;
    android) files+=(android_release.apk android_debug.apk) ;;
    ios) files+=(ios.zip) ;;
    *) echo "install_godot.sh: unknown platform $target (web, android, ios)" >&2; exit 1 ;;
  esac
done

temp=$(mktemp -d "${TMPDIR:-/tmp}/godot.XXXXXX")
trap 'rm -rf "$temp"' EXIT

sha512() {
  if command -v sha512sum > /dev/null; then sha512sum "$1"; else shasum -a 512 "$1"; fi |
    awk '{ print $1 }'
}

# Downloads Godot_v<version>_<slug> into the temporary folder, checks it.
download() {
  local name="Godot_v${version}_$1" expected
  expected=$(awk -v name="$name" '$2 == name { print $1 }' "$sums")
  if [[ -z $expected ]]; then
    echo "install_godot.sh: no SHA-512 pinned for $name in $sums" >&2
    exit 1
  fi
  echo "Downloading $name" >&2
  curl -fsSL --retry 3 -o "$temp/$name" \
    "https://downloads.godotengine.org/?version=$release&flavor=$flavor&slug=$1&platform=$2"
  if [[ $(sha512 "$temp/$name") != "$expected" ]]; then
    echo "install_godot.sh: $name does not match its pinned SHA-512" >&2
    exit 1
  fi
}

if [[ -x $binary ]] && [[ $("$binary" --version) == "$release.$flavor."* ]]; then
  echo "Godot $version is already in $dir" >&2
else
  download "$slug" "$platform"
  mkdir -p "$dir"
  unzip -q -o "$temp/Godot_v${version}_$slug" -d "$dir"
  rm "$temp/Godot_v${version}_$slug"
fi
mkdir -p "$dir/bin"
printf '#!/bin/sh\nexec "%s" "$@"\n' "$binary" > "$dir/bin/godot"
chmod +x "$dir/bin/godot"
if [[ -n ${GITHUB_PATH:-} ]]; then
  echo "$dir/bin" >> "$GITHUB_PATH"
fi

missing=()
for file in "${files[@]}"; do
  [[ -f "$templates/$file" ]] || missing+=("templates/$file")
done
if [[ $# -gt 0 && ${#missing[@]} -gt 0 ]]; then
  download export_templates.tpz templates
  mkdir -p "$templates"
  unzip -q -o -j "$temp/Godot_v${version}_export_templates.tpz" "${missing[@]}" -d "$templates"
elif [[ $# -gt 0 ]]; then
  echo "The export templates are already in $templates" >&2
fi
echo "$binary"
