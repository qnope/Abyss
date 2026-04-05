# Task 08 — Create monster_easy.svg

## Summary

Create the easy monster lair marker SVG at `assets/icons/map_content/monster_easy.svg`. Small cave with barely visible creature, green aura, and 1-star badge.

## Implementation Steps

1. Create file `assets/icons/map_content/monster_easy.svg` with viewBox `0 0 48 48`
2. **Defs section**:
   - Radial gradient `easyDenGrad`: center `#0A0E1A` → edge `#1A2D47` for cave interior
   - Filter `easyGlow` with `feGaussianBlur` stdDeviation=3, explicit region attrs
3. **Green aura**: Ellipse around cave area, filtered with `easyGlow`, fill `#69F0AE` at 20% opacity. Extends 4-5px beyond rocks
4. **Cave opening**: Semi-circle ~20x14px at center-bottom. Contour: irregular rocks in `#4A5568` with gradient to `#3A4558` inside. Fill interior with `easyDenGrad`
5. **Creature silhouette**: Small rounded body (r=3-4px) inside cave, `#050810` at 70% opacity. 2 lateral extensions (fins/legs). Two green eyes: circles r=0.8px, `#69F0AE` at 80% opacity
6. **1-star badge**: At position ~(36, 4):
   - Background circle r=5px, fill `#69F0AE` at 80% opacity
   - 5-pointed star 3px, fill `#0A0E1A` (no filter)
7. **Vegetation**: 1-2 small algae tufts on cave rocks, `#69F0AE` at 40% opacity

## Dependencies

- Task 01 (directory must exist)

## Test Plan

- File exists at `assets/icons/map_content/monster_easy.svg`
- Valid SVG 1.1 with viewBox `0 0 48 48`
- No text, no external fonts/images
- File size < 5 KB
- Green color coding (`#69F0AE`) clearly visible
- Star badge has exactly 1 star
- Accessibility: difficulty identifiable by both color (green) AND star count (1)

## Design Notes

- The star path for a 5-pointed star can be computed with: `M cx,cy-r L ... Z` using 5 outer + 5 inner points
- Smallest cave of the 3 monster variants
- ID prefix: `easy` for all gradient/filter IDs
- For `flutter_svg` compatibility: no CSS, no `<use>`, only basic SVG elements
