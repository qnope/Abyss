# Task 12 — Create faction_neutral.svg

## Summary

Create the neutral faction marker SVG at `assets/icons/map_content/faction_neutral.svg`. Subdued blue dome, smaller and dimmer than player base. Non-threatening but clearly "other".

## Implementation Steps

1. Create file `assets/icons/map_content/faction_neutral.svg` with viewBox `0 0 48 48`
2. **Defs section**:
   - Radial gradient `neutralGrad`: center `#42A5F5` at 50% opacity → edge `#2A3A50` at 40%
   - Filter `neutralGlow` with `feGaussianBlur` stdDeviation=2, explicit region attrs
3. **Halo**: Circle r=12px centered on dome, filtered with `neutralGlow`, fill `#42A5F5` at 12% opacity. Discreet blue glow
4. **Dome**: Half-sphere path ~22x16px centered (smaller than player base 28x20). Filled with `neutralGrad`
5. **Dome structure**: 3 meridian arcs only (vs 4-5 for player base = less advanced). Stroke `#42A5F5` at 30% opacity, stroke-width 0.4
6. **Base/pedestal**: Rounded rectangle 24x5px, fill `#1A2D47`, border in `#42A5F5` at 30% opacity
7. **Neutrality indicator**: Small balance/handshake symbol at dome top (~3x3px), `#42A5F5` at 60% opacity. Simple geometric abstraction (e.g., two mirrored arcs meeting at center = handshake)

## Dependencies

- Task 01 (directory must exist)

## Test Plan

- File exists at `assets/icons/map_content/faction_neutral.svg`
- Valid SVG 1.1 with viewBox `0 0 48 48`
- No text, no external fonts/images
- File size < 5 KB
- Clearly distinguishable from player_base (dimmer, smaller, blue not cyan)
- Clearly distinguishable from faction_hostile (blue not red, no spikes)
- Neutrality symbol visible at 48x48

## Design Notes

- Deliberately less luminous than player base — player base must dominate
- Blue tone (`#42A5F5` = oreBlue) is distinct from player's cyan (`#00E5FF`)
- Fewer structural lines (3 vs 4-5) suggests less technological advancement
- ID prefix: `neutral` for all gradient/filter IDs
- For `flutter_svg` compatibility: no CSS, no `<use>`, only basic SVG elements
