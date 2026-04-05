# Task 10 — Create monster_hard.svg

## Summary

Create the hard monster lair marker SVG at `assets/icons/map_content/monster_hard.svg`. Massive jagged cave with tentacled creature spilling out, intense red aura, claw marks, and 3-star badge.

## Implementation Steps

1. Create file `assets/icons/map_content/monster_hard.svg` with viewBox `0 0 48 48`
2. **Defs section**:
   - Radial gradient `hardDenGrad`: center `#0A0E1A` → edge `#1A1A2E`
   - Filter `hardGlow` with `feGaussianBlur` stdDeviation=4, explicit region attrs (generous: `-50%`, `200%`)
3. **Red aura**: Large ellipse around cave, filtered with `hardGlow`, fill `#FF5252` at 30% opacity. Extends 6-8px, nearly filling tile periphery
4. **Cave opening**: ~30x22px, occupying nearly 2/3 of tile bottom. Not a smooth semi-circle — jagged, dechiqueté shape with rock points. Rocks in `#4A5568` → `#1A1A2E`. Prominent stalactites AND stalagmites (triangles 3-5px) framing entrance like jaws
5. **Creature with tentacles**: Massive body in `#050810` at 90% opacity, filling most of cave opening. 3-4 tentacles extending OUT of cave toward tile edges, each 8-12px long curve paths, `#1A1A2E` at 80% opacity with tapering width. Eyes: 2 large circles r=1.5px, `#FF5252` at 90% opacity, with darker center pupil dots
6. **3-star badge**: At position ~(32, 2):
   - Background circle r=7px, fill `#FF5252` at 90% opacity
   - 3 five-pointed stars in arc, each 2px, fill `#0A0E1A`
7. **Danger particles**: 3-5 angular shards (triangles 0.5-1px) floating near entrance, `#FF5252` at 20-40% opacity
8. **Claw marks**: 2-3 parallel diagonal scratches on entrance rocks, stroke-width 0.5, `#2D3748`

## Dependencies

- Task 01 (directory must exist)

## Test Plan

- File exists at `assets/icons/map_content/monster_hard.svg`
- Valid SVG 1.1 with viewBox `0 0 48 48`
- No text, no external fonts/images
- File size < 5 KB
- Red color coding (`#FF5252`) clearly visible
- Star badge has exactly 3 stars
- Visually most imposing of the 3 monster variants
- Tentacles extend beyond cave boundary
- Accessibility: difficulty identifiable by both color (red) AND star count (3)

## Design Notes

- Largest cave (30x22), creature actively spills out — not hiding like easy/medium
- The red glow with stdDeviation=4 is the most intense filter — test performance
- Tentacles reaching out of the cave add to menace and fill more of the tile
- ID prefix: `hard` for all gradient/filter IDs
- For `flutter_svg` compatibility: no CSS, no `<use>`, only basic SVG elements
