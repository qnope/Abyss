# Task 11 — Create player_base.svg

## Summary

Create the player base marker SVG at `assets/icons/map_content/player_base.svg`. The most visually dominant element on the map — a bioluminescent cyan dome radiating energy.

## Implementation Steps

1. Create file `assets/icons/map_content/player_base.svg` with viewBox `0 0 48 48`
2. **Defs section**:
   - Radial gradient `baseGrad`: center `#00E5FF` at 80% opacity → mid `#448AFF` at 60% → edge `#0D1B2A` at 40%
   - Filter `baseGlow` with `feGaussianBlur` stdDeviation=4, generous region (`-50%`, `200%`)
   - Filter `baseGlow2` with `feGaussianBlur` stdDeviation=2 (secondary halo)
3. **Primary halo**: Circle r=18px centered on dome, filtered with `baseGlow`, fill `#00E5FF` at 25% opacity. Deliberately extends beyond tile
4. **Secondary halo**: Circle r=12px, filtered with `baseGlow2`, fill `#1DE9B6` at 15% opacity
5. **Dome**: Half-sphere path ~28x20px centered. Filled with `baseGrad`
6. **Dome structure**: 4-5 meridian arc lines (bottom to top curves), `#00E5FF` at 50% opacity, stroke-width 0.5. 2 horizontal parallel arcs
7. **Base/pedestal**: Rounded rectangle 30x6px, fill `#0D1B2A`, top border 0.5px in `#00E5FF` at 60% opacity
8. **Specular highlights**: 3-4 tiny dots (r=0.8px) on dome surface, `#E0F7FA` at 90% opacity
9. **Bioluminescent particles**: 5-7 circles of varied sizes (r=0.3-1px) within 20px radius of dome. Alternating `#00E5FF` and `#1DE9B6` at 20-50% opacity

## Dependencies

- Task 01 (directory must exist)

## Test Plan

- File exists at `assets/icons/map_content/player_base.svg`
- Valid SVG 1.1 with viewBox `0 0 48 48`
- No text, no external fonts/images
- File size < 5 KB
- Must be the brightest/most dominant icon of all map content
- Cyan glow clearly distinguishes it from neutral (blue) and hostile (red) factions

## Design Notes

- **Most luminous asset** — intentionally brighter than everything else on the map
- The halo purposely extends beyond the 48x48 tile (clipped by Flutter, but creates edge glow when adjacent tiles render)
- Two-layer halo (cyan + teal) creates depth and richness
- ID prefix: `base` for all gradient/filter IDs
- For `flutter_svg` compatibility: no CSS, no `<use>`, only basic SVG elements
