# Task 07 — Create ruins.svg

## Summary

Create the ancient ruins marker SVG at `assets/icons/map_content/ruins.svg`. Broken arch with fallen column, nacré/purple glow, and floating pearl particles.

## Implementation Steps

1. Create file `assets/icons/map_content/ruins.svg` with viewBox `0 0 48 48`
2. **Defs section**:
   - Linear gradient `ruinsStoneGrad`: `#5A6678` (base) → `#7B8C9F` (top)
   - Filter `ruinsGlow` with `feGaussianBlur` stdDeviation=2.5, explicit region attrs
3. **Nacré glow**: Ellipse behind arch, filtered with `ruinsGlow`, fill `#B388FF` at 25% opacity
4. **Broken arch**: Left half intact — path curving from bottom to 2/3 height (elegant arch). Right half is a jagged stump. Fill with `ruinsStoneGrad`
5. **Fallen column**: Diagonal cylindrical shape at arch base, ~16px long, 3px wide. Gradient `#6B7C8F` → `#4A5568`. Broken cross-section circles at ends
6. **Inscriptions**: 2-3 very fine lines (stroke-width 0.3) on intact arch surface — geometric patterns (parallels, spirals). `#B388FF` at 30% opacity
7. **Floor debris**: 3-5 small angular polygons (1-3px) at arch base, `#4A5568` at 70% opacity
8. **Pearl particles**: 3-4 tiny circles (r=0.5-1) floating around ruins, `#E0F7FA` at 30-50% opacity

## Dependencies

- Task 01 (directory must exist)

## Test Plan

- File exists at `assets/icons/map_content/ruins.svg`
- Valid SVG 1.1 with viewBox `0 0 48 48`
- No text, no external fonts/images
- File size < 5 KB
- Purple/pearl glow distinguishes it from other content markers

## Design Notes

- The purple glow (`#B388FF`) is unique to ruins — no other content uses this color
- Pearl particles (`#E0F7FA`) hint at Pearl resource availability
- ID prefix: `ruins` for all gradient/filter IDs
- For `flutter_svg` compatibility: no CSS, no `<use>`, only basic SVG elements
