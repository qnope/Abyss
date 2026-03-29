# Task 04 — Create ore.svg

## Summary

Hand-code the oceanic ore (metal) resource SVG icon: a faceted geometric crystal (hexagonal gem style) with blue bioluminescent glow and internal gradients.

## Implementation Steps

1. **Create file** `assets/icons/resources/ore.svg`.

2. **SVG structure** (viewBox `0 0 64 64`):
   - `<defs>`:
     - `<linearGradient id="oreGrad">`: from `#1565C0` (deep blue) to `#42A5F5` (bioluminescent blue).
     - `<linearGradient id="oreFacet">`: lighter variant for highlight facets.
     - `<filter id="oreGlow">`: `<feGaussianBlur stdDeviation="3">` + `<feMerge>`.
   - `<g filter="url(#oreGlow)">`:
     - Main crystal shape: `<polygon>` with 6-8 points forming a hexagonal gem.
     - 2-3 internal facet lines: `<line>` or `<path>` elements showing crystal faces, using the lighter gradient.
     - Small highlight spot near top for a reflective glint.

3. **Color palette**:
   - Gradient: `#1565C0` -> `#42A5F5` (matches `AbyssColors.oreBlue`).
   - Facet highlights: lighter blue `#64B5F6` or `#90CAF9`.
   - Glow: blue halo around the crystal.

## Dependencies

- Task 01 (assets directory must exist).

## Test Plan

- Open the SVG in a browser or viewer at 24px, 48px, 64px — verify readability.
- Validate XML is well-formed.
- Shape is clearly geometric/angular (distinct from organic algae/coral).

## Design Considerations

- Use sharp angles and straight edges to convey "mineral/metal".
- Facet lines should be subtle enough to not clutter at 24px but visible at 48px+.
- The crystal should be vertically oriented (taller than wide) for a gem-like silhouette.
