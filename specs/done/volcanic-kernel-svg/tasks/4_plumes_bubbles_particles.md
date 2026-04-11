# Task 4: Hydrothermal Plumes, Bubbles, and Particles

## Summary

Add the underwater atmospheric elements: hydrothermal plumes rising from the crater and vents, scattered bubbles, and glowing ember/particle effects.

## Implementation Steps

1. **Hydrothermal plume 1 (main, from crater):**
   - A curved `<path>` rising from the crater (~x=26, y=16) upward and leftward (~x=18, y=2).
   - Stroke `url(#vkPlumeGrad)`, width 2-2.5, `stroke-linecap="round"`.
   - Use quadratic/cubic bezier for a natural undulating curve.
   - Opacity 0.5-0.6.

2. **Hydrothermal plume 2 (secondary, from crater):**
   - Another `<path>` rising from the crater (~x=30, y=16) upward and rightward (~x=40, y=4).
   - Thinner stroke (1.5), `#00BCD4`, opacity 0.4.
   - Different curvature than plume 1 for variety.

3. **Hydrothermal plume 3 (from side vent, optional):**
   - A short wispy `<path>` rising from the side vent area (~x=42, y=34) upward (~x=44, y=24).
   - Stroke `#00E5FF`, width 1, opacity 0.3.

4. **Bubbles** — at least 6 `<circle>` elements of varying sizes:
   - Sizes: r = 0.5 to 2.0.
   - Color: `#00E5FF`.
   - Opacity: 0.15 to 0.4 (smaller = more transparent).
   - Placement: scattered above and around the crater and plumes, rising upward. Some near the side vent. Not in a grid — organic, random-feeling placement.
   - Example positions: (20,8), (24,4), (30,10), (36,6), (44,12), (18,14), (38,2), (42,8).

5. **Ember/particle elements** — at least 4 `<circle>` elements near the crater and lava flows:
   - Color: `#FF6D00` or `#FFAB00`.
   - Sizes: r = 0.4 to 1.2.
   - Opacity: 0.4 to 0.8.
   - Placement: clustered near the crater opening and along the upper portions of lava flows — they represent ejected volcanic material.
   - Example positions: (26,14), (30,16), (22,18), (34,18), (28,12).

6. **Additional suspended particles** — 2-3 very small dots (`r < 0.5`) in the water column away from the volcano:
   - Mix of `#00E5FF` (cold) and `#FF6D00` (hot) at very low opacity (0.15-0.25).
   - Represent general underwater particulate matter.

## Dependencies

- Task 1 (defs: `vkPlumeGrad`, `vkGlow`).
- Task 2 (crater position for plume origins).
- Task 3 (side vent position for plume 3 / nearby bubbles).

## Test Plan

- At least 2 hydrothermal plume paths visible (curved, rising).
- At least 6 bubble elements with varying size and opacity.
- At least 4 ember/particle elements near the crater.
- Plumes use cyan colors (`#00E5FF`, `#00BCD4`).
- Embers use orange colors (`#FF6D00`, `#FFAB00`).
- All elements placed organically (not in grid patterns).

## Notes

- Bubbles and particles are what make the icon read as "underwater." Without them, it could look like a surface volcano.
- Plume curves should rise upward naturally — water current bends them slightly to one side.
- Embers near the crater reinforce the volcanic heat source.
- This task likely brings the SVG past 150 lines.
