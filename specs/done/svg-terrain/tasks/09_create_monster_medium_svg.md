# Task 09 — Create monster_medium.svg

## Summary

Create the medium monster lair marker SVG at `assets/icons/map_content/monster_medium.svg`. Larger cave with stalactites, partially visible creature with orange eyes, orange aura, and 2-star badge.

## Implementation Steps

1. Create file `assets/icons/map_content/monster_medium.svg` with viewBox `0 0 48 48`
2. **Defs section**:
   - Radial gradient `medDenGrad`: center `#0A0E1A` → edge `#2D3748` for cave interior
   - Filter `medGlow` with `feGaussianBlur` stdDeviation=3.5, explicit region attrs
3. **Orange aura**: Ellipse around cave, filtered with `medGlow`, fill `#FFD740` at 25% opacity. Extends 5-6px beyond rocks
4. **Cave opening**: Semi-circle ~26x18px at center-bottom. Larger and more angular than easy. Rocks in `#4A5568` → `#2D3748`. 2-3 stalactite triangles hanging from top of opening, in `#3A4558`
5. **Creature silhouette**: Oval body 6x4px, `#050810` at 80% opacity. 4 extensions (tentacles/legs), partially visible — spills out of shadow. Eyes: 2 circles r=1px, `#FFD740` at 90% opacity
6. **2-star badge**: At position ~(34, 3):
   - Background circle r=6px, fill `#FFD740` at 85% opacity
   - 2 five-pointed stars side by side, each 2.5px, fill `#0A0E1A`
7. **Bone debris**: 1-2 small white bone shapes at cave entrance, `#7B9CC0` at 30% opacity

## Dependencies

- Task 01 (directory must exist)

## Test Plan

- File exists at `assets/icons/map_content/monster_medium.svg`
- Valid SVG 1.1 with viewBox `0 0 48 48`
- No text, no external fonts/images
- File size < 5 KB
- Orange/yellow color coding (`#FFD740`) clearly visible
- Star badge has exactly 2 stars
- Visually larger/more imposing than monster_easy
- Accessibility: difficulty identifiable by both color (orange) AND star count (2)

## Design Notes

- Cave is noticeably bigger than easy variant (26x18 vs 20x14)
- Creature is larger and partially exits cave shadow
- Stalactites add menace missing from easy variant
- ID prefix: `med` for all gradient/filter IDs
- For `flutter_svg` compatibility: no CSS, no `<use>`, only basic SVG elements
