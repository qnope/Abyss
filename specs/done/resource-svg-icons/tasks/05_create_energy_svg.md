# Task 05 — Create energy.svg

## Summary

Hand-code the energy resource SVG icon: a lightning bolt or energy orb with yellow bioluminescent glow and radiant gradients.

## Implementation Steps

1. **Create file** `assets/icons/resources/energy.svg`.

2. **SVG structure** (viewBox `0 0 64 64`):
   - `<defs>`:
     - `<linearGradient id="energyGrad">`: from `#FF8F00` (yellow-orange) to `#FFD740` (bright yellow).
     - `<radialGradient id="energyRadial">`: center bright `#FFD740`, outer `#FF8F00` for orb glow.
     - `<filter id="energyGlow">`: `<feGaussianBlur stdDeviation="4">` + `<feMerge>` (slightly stronger glow for energy).
   - `<g filter="url(#energyGlow)">`:
     - Lightning bolt: `<polygon>` with a classic zigzag shape (3 segments).
     - Small radiating lines or dots around the bolt to suggest energy emission.

3. **Color palette**:
   - Gradient: `#FF8F00` -> `#FFD740` (matches `AbyssColors.energyYellow`).
   - Glow: yellow radiant halo.

## Dependencies

- Task 01 (assets directory must exist).

## Test Plan

- Open the SVG in a browser or viewer at 24px, 48px, 64px — verify readability.
- Validate XML is well-formed.
- Lightning bolt shape is instantly recognizable even at 24px.

## Design Considerations

- Lightning bolt is the most universally recognizable "energy" symbol — prefer it over an orb.
- Keep the zigzag simple (3 segments max) for small-size clarity.
- Slightly stronger glow (stdDeviation 4) to convey radiant energy.
- Radiating accents should be very subtle or omitted at risk of clutter.
