# Task 3: Lava Flows and Side Vent

## Summary

Add 2-3 asymmetric lava flow rivulets down the volcano flanks and at least 1 secondary side vent/fissure with its own glow.

## Implementation Steps

1. **Lava flow 1 (left flank)** — a `<path>` curving from near the crater down the left side:
   - Start near (~x=24, y=20), curve down to (~x=14, y=48).
   - Irregular width: use `stroke-width` of 2-2.5 with `stroke-linecap="round"`.
   - Stroke `url(#vkLavaGrad)` or solid `#FF3D00`.
   - Add a parallel thinner glow path behind it (same shape, wider stroke, lower opacity ~0.3, filter `url(#vkGlow)`).

2. **Lava flow 2 (right flank)** — a `<path>` curving from crater area down the right:
   - Start near (~x=32, y=20), curve right to (~x=46, y=50).
   - Same treatment as flow 1 but different curvature to maintain asymmetry.
   - Stroke `#FF6D00`, width 1.5-2.

3. **Lava flow 3 (optional shorter flow)** — a shorter rivulet branching off flow 1 or 2:
   - Only extends partway down a flank.
   - Thinner stroke (1-1.5), `#FF9100`.

4. **Side vent/fissure** on the right flank (~x=42, y=36):
   - A small crack `<path>` (2-3 short line segments) in the rock.
   - Stroke `#4E342E`, width 1.
   - Behind/inside the crack: a small `<ellipse>` or `<circle>` filled with `#FF6D00`, opacity 0.6, with `filter="url(#vkGlow)"` for a lava glow emanating from the fissure.
   - A tiny vapor wisp `<path>` rising from the vent (1-2 strokes in `#00E5FF`, opacity 0.3) — connects to the hydrothermal theme.

## Dependencies

- Task 1 (defs: `vkLavaGrad`, `vkGlow`).
- Task 2 (volcano body must exist to know exact flank coordinates).

## Test Plan

- At least 2 lava flow paths are visible flowing down the flanks.
- At least 1 side vent/fissure with its own glow is present.
- Lava flows are placed asymmetrically (not mirrored).
- Glow effects use `filter="url(#vkGlow)"`.
- Colors match the SPEC palette: `#FF3D00`, `#FF6D00`, `#FF9100`.

## Notes

- Lava flows should follow the contour of the volcano body — they sit on top of the rock, not floating in space.
- The side vent adds realism and breaks symmetry (SPEC requirement).
- The vapor wisp from the side vent is a small detail connecting to the hydrothermal plume theme in Task 4.
