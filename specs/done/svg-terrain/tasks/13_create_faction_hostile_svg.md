# Task 13 — Create faction_hostile.svg

## Summary

Create the hostile faction marker SVG at `assets/icons/map_content/faction_hostile.svg`. Red menacing dome with defensive spikes and aggressive design.

## Implementation Steps

1. Create file `assets/icons/map_content/faction_hostile.svg` with viewBox `0 0 48 48`
2. **Defs section**:
   - Radial gradient `hostileGrad`: center `#FF5252` at 50% opacity → edge `#2A1015` at 60%
   - Filter `hostileGlow` with `feGaussianBlur` stdDeviation=2.5, explicit region attrs
3. **Red halo**: Circle r=13px centered on dome, filtered with `hostileGlow`, fill `#FF5252` at 15% opacity
4. **Dome**: Half-sphere path ~22x16px (same size as neutral). Filled with `hostileGrad`
5. **Defensive spikes**: 4-6 triangular points (3-4px tall) radiating outward from dome base. Fill `#4A2020`, highlight `#FF5252` at 30% opacity. Creates fortified/aggressive silhouette
6. **Dome structure**: 3 meridian arcs in `#FF5252` at 35% opacity, stroke-width 0.5
7. **Red sentinel lights**: 2-3 dots (r=1px) on dome surface, `#FF5252` at 80% opacity. Positioned to suggest "eyes" or surveillance. No white specular highlights (unlike player base)
8. **Base/pedestal**: Rounded rectangle 24x5px, fill `#1A1015` (darker than neutral), border `#FF5252` at 40% opacity
9. **Hostility indicator**: Small crossed-swords or skull symbol at dome top (~3x3px), `#FF5252` at 70% opacity. Simple geometric abstraction

## Dependencies

- Task 01 (directory must exist)

## Test Plan

- File exists at `assets/icons/map_content/faction_hostile.svg`
- Valid SVG 1.1 with viewBox `0 0 48 48`
- No text, no external fonts/images
- File size < 5 KB
- Red color immediately communicates threat
- Spikes distinguish from neutral (rounded) and player base (no spikes)
- Hostile symbol visible at 48x48

## Design Notes

- Same dome size as neutral but radically different feel due to color + spikes
- Red (`#FF5252` = error color) triggers danger association
- Spikes are the key differentiator from neutral faction — unique to hostile
- No white specular highlights — only red lights, creating "inhuman" feel
- ID prefix: `hostile` for all gradient/filter IDs
- For `flutter_svg` compatibility: no CSS, no `<use>`, only basic SVG elements
