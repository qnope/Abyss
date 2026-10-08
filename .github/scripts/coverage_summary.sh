#!/usr/bin/env bash
# Writes a Markdown coverage report from an lcov file.
# Usage: coverage_summary.sh <lcov.info> [badge.json]
# When badge.json is given, also writes a shields.io endpoint badge there.
set -euo pipefail

lcov_file="${1:-coverage/lcov.info}"
badge_file="${2:-}"

# One "found hit file" line per source file, paths relative to lib/.
# Generated files (*.g.dart) are left out.
per_file=$(awk '
  /^SF:/ { file = substr($0, 4); sub(/^.*\/lib\//, "lib/", file)
           skip = file ~ /\.g\.dart$/ }
  skip { next }
  /^LF:/ { found[file] += substr($0, 4) }
  /^LH:/ { hit[file] += substr($0, 4) }
  END { for (f in found) print found[f], hit[f], f }
' "$lcov_file")

row() {
  awk -v name="$1" -v f="$2" -v h="$3" 'BEGIN {
    p = f == 0 ? 100 : 100 * h / f
    icon = p >= 80 ? "🟢" : (p >= 50 ? "🟡" : "🔴")
    printf "| `%s` | %d | %d | %s %.1f%% |\n", name, f, h, icon, p
  }'
}

read -r total_found total_hit files < <(
  echo "$per_file" | awk '{ f += $1; h += $2; n++ } END { print f + 0, h + 0, n + 0 }'
)
total_pct=$(awk -v f="$total_found" -v h="$total_hit" \
  'BEGIN { printf "%.1f", f == 0 ? 100 : 100 * h / f }')

if [[ -n "$badge_file" ]]; then
  color=$(awk -v p="$total_pct" 'BEGIN {
    p += 0
    print (p >= 80 ? "brightgreen" : (p >= 50 ? "yellow" : "red"))
  }')
  printf '{"schemaVersion":1,"label":"coverage","message":"%s%%","color":"%s"}\n' \
    "$total_pct" "$color" > "$badge_file"
fi

echo "## Code coverage: ${total_pct}%"
echo
echo "${total_hit} of ${total_found} lines covered across ${files} files."
echo
echo "| Layer | Lines | Covered | Coverage |"
echo "|---|---:|---:|---:|"
echo "$per_file" | awk '{
  n = split($3, parts, "/")
  layer = n > 2 ? parts[1] "/" parts[2] : parts[1] " (root)"
  f[layer] += $1; h[layer] += $2
} END { for (l in f) print f[l], h[l], l }' | sort -k3 |
  while read -r f h name; do row "$name" "$f" "$h"; done
echo
echo "<details><summary>Least covered files</summary>"
echo
echo "| File | Lines | Covered | Coverage |"
echo "|---|---:|---:|---:|"
echo "$per_file" | awk '{ printf "%.4f %s\n", $1 == 0 ? 100 : 100 * $2 / $1, $0 }' |
  sort -n -k1,1 -k2,2nr | head -n 20 |
  while read -r _ f h name; do row "$name" "$f" "$h"; done
echo
echo "</details>"
