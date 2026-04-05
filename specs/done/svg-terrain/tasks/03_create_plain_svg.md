# Task 03 — Create plain.svg

## Summary

Create the underwater plain terrain tile SVG at `assets/icons/terrain/plain.svg`. Open, airy blue tile with sandy bottom, algae filaments, and plankton.

## Implementation Steps

1. Create file `assets/icons/terrain/plain.svg` with viewBox `0 0 48 48`
2. **Defs section**: Define a linear gradient `plainSandGrad` vertical from `#42A5F5` 15% opacity (top) to `#2E7BC8` 25% opacity (bottom) for the sand layer
3. **Background layer**: Rectangle 48x48, fill `#42A5F5` at 40% opacity
4. **Sand layer**: Rectangle covering bottom half, filled with `plainSandGrad`. Add scattered dots (r=0.3-0.5) in `#5BB8FF` at 20% opacity for grain texture
5. **Current ripples**: 2-3 horizontal wavy lines in bottom half, stroke-width 0.4, `#5BB8FF` at 15% opacity
6. **Floating algae**: 2-3 S-curve paths rising from bottom, 8-15px tall, stroke 0.8-1px. Gradient along path: `#69F0AE` at 60% opacity (base) → `#69F0AE` at 20% opacity (tip)
7. **Plankton particles**: 3-5 tiny circles (r=0.5-0.8) in upper half, `#1DE9B6` at 20-30% opacity

## Dependencies

- Task 01 (directory must exist)

## Test Plan

- File exists at `assets/icons/terrain/plain.svg`
- Valid SVG 1.1 with viewBox `0 0 48 48`
- No text, no external fonts/images
- File size < 5 KB
- Uses only: `#42A5F5`, `#2E7BC8`, `#5BB8FF`, `#69F0AE`, `#1DE9B6`

## Design Notes

- **No glow filter** on this tile — plain is calm, the visual "negative space" that highlights other terrains
- Semi-transparent blue background distinguishes from pink reef
- For `flutter_svg` compatibility: no CSS, no `<use>`, only basic SVG elements
- Algae gradient can be achieved with `<linearGradient>` along the algae path using `gradientUnits="userSpaceOnUse"`
