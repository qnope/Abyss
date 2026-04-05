# Task 14 — Validate All SVGs

## Summary

Validate all 12 SVG files for technical correctness, consistency, and spec compliance.

## Implementation Steps

1. **Structural validation** for each of the 12 SVGs:
   - Verify viewBox is exactly `0 0 48 48`
   - Verify `xmlns="http://www.w3.org/2000/svg"` is present
   - Verify no `<text>`, `<font>`, `<image>`, `<use>`, or `<style>` elements
   - Verify no external references (xlink:href to URLs, font-face, etc.)
   - Verify no CSS embedded (no `<style>` blocks, no `style=` attributes — use inline SVG attributes)

2. **File size check**: Each file must be < 5 KB
   ```bash
   for f in assets/icons/terrain/*.svg assets/icons/map_content/*.svg; do
     size=$(wc -c < "$f")
     echo "$f: $size bytes"
     [ "$size" -gt 5120 ] && echo "WARNING: $f exceeds 5KB!"
   done
   ```

3. **ID collision check**: Verify no duplicate gradient/filter IDs across all files
   ```bash
   grep -h 'id="' assets/icons/terrain/*.svg assets/icons/map_content/*.svg | sort | uniq -d
   ```

4. **Color palette check**: Verify all hex colors used are from the spec palette:
   - Terrain backgrounds: `#FF6E91`, `#42A5F5`, `#4A5568`, `#1A1A2E`
   - Derived tints: `#CC5577`, `#D45A7A`, `#FF80AB`, `#2E7BC8`, `#5BB8FF`, `#5A6678`, `#3A4558`, `#2D3748`, `#6B7C8F`, `#2A1A3E`, `#1F1F35`
   - Bioluminescence: `#00E5FF`, `#448AFF`, `#1DE9B6`, `#B388FF`, `#69F0AE`, `#FF80AB`
   - Functional: `#FF4500`, `#FF5252`, `#FF8A65`, `#FFD740`, `#E0F7FA`
   - Deep sea: `#0A0E1A`, `#0D1B2A`, `#1A2D47`
   - Faction: `#2A3A50`, `#3A5070`, `#5A7090`, `#2A1015`, `#4A2020`, `#1A1015`
   - Creature: `#050810`, `#7B9CC0`, `#7B8C9F`

5. **Filter region check**: Verify all `<filter>` elements have explicit `x`, `y`, `width`, `height` attributes

6. **File inventory**: Confirm exactly 12 files exist:
   - `assets/icons/terrain/`: reef.svg, plain.svg, rock.svg, fault.svg
   - `assets/icons/map_content/`: resource_bonus.svg, ruins.svg, monster_easy.svg, monster_medium.svg, monster_hard.svg, player_base.svg, faction_neutral.svg, faction_hostile.svg

## Dependencies

- Tasks 02-13 (all SVGs must be created)

## Test Plan

- All 12 files pass structural validation
- All 12 files are under 5 KB
- No ID collisions across files
- No off-palette colors
- All filters have explicit regions
- Run `flutter analyze` to verify no asset issues

## Notes

- This is a final quality gate before the SVG assets are considered complete
- If any file fails, fix it in-place and re-validate
