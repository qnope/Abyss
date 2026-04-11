# Task 2: Volcano Body and Crater

## Summary

Draw the main volcanic mound — an asymmetric, craggy conical shape with layered rock textures — and the open crater at the top emitting a radial glow.

## Implementation Steps

1. **Volcano silhouette** — a single `<path>` forming an irregular conical mound:
   - Base spans roughly x=8 to x=56, sitting on the seabed (~y=52).
   - Peak offset left of center (~x=28, y=16) for asymmetry.
   - Edges are jagged/craggy (not smooth curves) — use short line segments with slight variations.
   - Fill with `url(#vkRockGrad)`.

2. **Rock texture layers** — 3-4 additional `<path>` elements overlaid on the body:
   - Each traces a horizontal-ish line across the flank at different heights.
   - Use darker shades (`#1A1A1A`, `#2D2D2D`) with low opacity (0.3-0.5) to suggest layered rock strata.
   - Lines should be slightly wavy/irregular, not straight.

3. **Crack/ridge lines** — 4-5 thin `<path>` strokes:
   - Short diagonal cracks running down the rocky surface.
   - Stroke `#4E342E`, width 0.5-0.8, opacity 0.4-0.6.
   - Placed asymmetrically across both flanks.

4. **Shadow lines** — 2-3 `<path>` elements on the right flank (shadow side):
   - Darker fill or stroke (`#1A1A1A`, opacity 0.3) to add depth/volume.

5. **Crater opening** at the peak:
   - An elliptical depression `<ellipse>` at the peak (~cx=28, cy=18, rx=6, ry=3).
   - Darker rim: `<ellipse>` stroke `#2D2D2D`, width 1.5.
   - Interior glow: slightly smaller `<ellipse>` filled with `url(#vkCraterGlow)` to create the bright radial glow from within.
   - A bright center dot: tiny `<circle>` (r=1.5) at crater center, fill `#FFAB00`, opacity 0.9.

## Dependencies

- Task 1 (SVG scaffold and defs must exist).

## Test Plan

- Volcano body is visible as a craggy, asymmetric cone shape.
- Crater glow uses `url(#vkCraterGlow)` radial gradient.
- Peak is not centered (asymmetric composition).
- At least 3 rock texture lines and 4 crack/ridge lines present.
- No `<style>` blocks used.

## Notes

- The peak is intentionally offset left (~x=28) rather than centered at x=32. This asymmetry is a core design principle from the SPEC.
- Rock colors: `#1A1A1A`, `#2D2D2D`, `#3E2723`, `#4E342E`.
- Crater glow must use radial gradient fading from bright center outward (SPEC acceptance criteria).
