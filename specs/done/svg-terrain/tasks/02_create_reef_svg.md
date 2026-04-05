# Task 02 — Create reef.svg

## Summary

Create the coral reef terrain tile SVG at `assets/icons/terrain/reef.svg`. Semi-transparent pink tile with coral formations and bioluminescent glow.

## Implementation Steps

1. Create file `assets/icons/terrain/reef.svg` with viewBox `0 0 48 48`
2. **Defs section**: Define a radial gradient for coral (center `#FF6E91` → edge `#CC5577`), and a filter `reefGlow` using `feGaussianBlur` stdDeviation=2
3. **Background layer**: Rectangle 48x48, fill `#FF6E91` at 40% opacity (`opacity="0.4"`)
4. **Main coral formations**: 2-3 organic branching shapes rising from bottom edge. Use the radial gradient. Irregular, rounded silhouettes (Diploria/Acropora-style). Paths with curves (Q/C commands)
5. **Secondary coral**: Small rounded shapes at bottom, fill `#D45A7A`
6. **Particles**: 4-6 small circles (r=1-1.5), upper half of tile, fill `#FF80AB` at 30-50% opacity
7. **Bioluminescent glow**: Circle centered on largest coral, filtered with `reefGlow`, fill `#FF80AB` at 20% opacity
8. **Sand texture**: Fine wavy lines at bottom (stroke-width 0.3-0.5), `#CC5577` at 20% opacity

## Dependencies

- Task 01 (directory must exist)

## Test Plan

- File exists at `assets/icons/terrain/reef.svg`
- Valid SVG 1.1 with viewBox `0 0 48 48`
- No text, no external fonts/images
- File size < 5 KB
- Uses only colors from spec: `#FF6E91`, `#CC5577`, `#D45A7A`, `#FF80AB`

## Design Notes

- **Existing SVG pattern reference**: See `assets/icons/buildings/headquarters.svg` for gradient/filter conventions
- **Key difference**: Terrain tiles use 48x48 viewBox (not 64x64 like building/unit icons)
- **ID prefixing**: Use `reef` prefix for all gradient/filter IDs to avoid collisions (e.g., `reefGrad`, `reefGlow`)
- Semi-transparent background is essential — the black `#0A0E1A` game background must show through
- For `flutter_svg` compatibility: no CSS, no `<use>`, only basic SVG elements with inline attributes
- Filter must have explicit `x`, `y`, `width`, `height` attributes to prevent blur clipping
