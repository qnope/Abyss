# Task 03 — Create coral.svg

## Summary

Hand-code the coral (construction) resource SVG icon: a branching coral structure with pink bioluminescent glow and gradients.

## Implementation Steps

1. **Create file** `assets/icons/resources/coral.svg`.

2. **SVG structure** (viewBox `0 0 64 64`):
   - `<defs>`:
     - `<linearGradient id="coralGrad">`: from `#C2185B` (deep pink) to `#FF6E91` (bioluminescent pink).
     - `<filter id="coralGlow">`: `<feGaussianBlur stdDeviation="3">` + `<feMerge>`.
   - `<g filter="url(#coralGlow)">`:
     - Main trunk: vertical `<path>` from base.
     - 3-4 branching arms: `<path>` elements curving outward, with rounded tips.
     - Branch tips should be slightly brighter (use gradient direction to achieve this).

3. **Color palette**:
   - Gradient: `#C2185B` -> `#FF6E91` (matches `AbyssColors.coralPink`).
   - Glow: pink halo at branch tips.

## Dependencies

- Task 01 (assets directory must exist).

## Test Plan

- Open the SVG in a browser or viewer at 24px, 48px, 64px — verify readability.
- Validate XML is well-formed.
- Shape is clearly distinct from algae (branching vs wavy leaves).

## Design Considerations

- Coral branches should fork at least once to read as "coral" at small sizes.
- Round tips to distinguish from crystal/ore.
- Keep branch count low (3-4) for clarity at 24px.
