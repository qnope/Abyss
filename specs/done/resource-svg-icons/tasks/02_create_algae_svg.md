# Task 02 — Create algae.svg

## Summary

Hand-code the algae (food) resource SVG icon: a stylized seaweed strand with 2-3 wavy leaves, using green bioluminescent glow and gradients.

## Implementation Steps

1. **Create file** `assets/icons/resources/algae.svg`.

2. **SVG structure** (viewBox `0 0 64 64`):
   - `<defs>`:
     - `<linearGradient id="algaeGrad">`: from `#2E7D32` (dark green) to `#69F0AE` (bioluminescent green).
     - `<filter id="algaeGlow">`: `<feGaussianBlur stdDeviation="3">` + `<feMerge>` combining blur and original.
   - `<g filter="url(#algaeGlow)">`:
     - Central stem: curved `<path>` from bottom-center upward.
     - 2-3 wavy leaf shapes: `<path>` elements using cubic bezier curves, filled with `url(#algaeGrad)`.
   - Leaves should be thick enough to remain visible at 24px.

3. **Color palette**:
   - Gradient: `#2E7D32` -> `#69F0AE` (matches `AbyssColors.algaeGreen`).
   - Glow: soft green halo via blur filter.

## Dependencies

- Task 01 (assets directory must exist).

## Test Plan

- Open the SVG in a browser or viewer at 24px, 48px, 64px — verify readability.
- Validate XML is well-formed.
- File is under 2KB (lightweight).

## Design Considerations

- Keep shapes simple (2-3 leaves, 1 stem) so details survive at 24px.
- Glow `stdDeviation` between 2 and 4 for a visible but not overwhelming halo.
- No text or embedded images.
