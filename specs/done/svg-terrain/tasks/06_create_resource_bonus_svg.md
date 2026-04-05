# Task 06 — Create resource_bonus.svg

## Summary

Create the resource deposit marker SVG at `assets/icons/map_content/resource_bonus.svg`. An underwater treasure chest, partially open, with golden light escaping.

## Implementation Steps

1. Create file `assets/icons/map_content/resource_bonus.svg` with viewBox `0 0 48 48`
2. **Defs section**:
   - Linear gradient `chestGrad` vertical: `#3A5070` (top/lid) → `#2A3A50` (bottom/body)
   - Linear gradient `chestGlowGrad` vertical: `#FFD740` at 60% opacity (base) → `#FFD740` at 0% (top)
   - Filter `chestGlow` with `feGaussianBlur` stdDeviation=1.5, explicit region attrs
3. **Shadow**: Ellipse below chest position, fill `#0A0E1A` at 30% opacity, slightly wider than chest
4. **Chest body**: Rounded rectangle ~24x18px centered, filled with `chestGrad`
5. **Metal bands**: 2 horizontal strokes across chest body, `#5A7090`, stroke-width 0.8
6. **Chest lid**: Slightly angled (15-20° open) using a transform or path, same gradient top portion
7. **Golden light beam**: Triangular path expanding upward from opening, filled with `chestGlowGrad`, filtered with `chestGlow`
8. **Golden particles**: 4-6 small diamonds or circles (1-1.5px) around beam, `#FFD740` at 40-70% opacity

## Dependencies

- Task 01 (directory must exist)

## Test Plan

- File exists at `assets/icons/map_content/resource_bonus.svg`
- Valid SVG 1.1 with viewBox `0 0 48 48`
- No text, no external fonts/images
- File size < 5 KB
- Overlay test: must be readable when composited on any of the 4 terrain tiles

## Design Notes

- This is a **content overlay**, superposed on terrain tiles — keep the design centered and compact
- ID prefix: `chest` for all gradient/filter IDs
- The golden glow (`#FFD740`) must contrast with all terrain backgrounds (pink reef, blue plain, gray rock, dark fault)
- For `flutter_svg` compatibility: no CSS, no `<use>`, only basic SVG elements
