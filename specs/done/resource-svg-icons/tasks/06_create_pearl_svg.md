# Task 06 — Create pearl.svg

## Summary

Hand-code the pearl (rare) resource SVG icon: a spherical pearl with a nacreous sheen, highlight reflection, and a subtle cyan/white glow.

## Implementation Steps

1. **Create file** `assets/icons/resources/pearl.svg`.

2. **SVG structure** (viewBox `0 0 64 64`):
   - `<defs>`:
     - `<radialGradient id="pearlGrad">`: center `#FFFFFF` (white), mid `#E0F7FA` (pale cyan), outer `#B2EBF2` (deeper cyan).
     - `<radialGradient id="pearlSheen">`: off-center highlight for nacreous reflection.
     - `<filter id="pearlGlow">`: `<feGaussianBlur stdDeviation="2.5">` + `<feMerge>` (subtle, elegant glow).
   - `<g filter="url(#pearlGlow)">`:
     - Main sphere: `<circle>` filled with `url(#pearlGrad)`.
     - Highlight spot: smaller `<ellipse>` with `url(#pearlSheen)`, positioned upper-left for a reflective glint.
     - Optional: thin crescent shadow `<path>` at bottom-right for depth.

3. **Color palette**:
   - Gradient: `#B2EBF2` -> `#E0F7FA` -> `#FFFFFF` (matches `AbyssColors.pearlWhite`).
   - Glow: subtle white/cyan halo.

## Dependencies

- Task 01 (assets directory must exist).

## Test Plan

- Open the SVG in a browser or viewer at 24px, 48px, 64px — verify readability.
- Validate XML is well-formed.
- Pearl is clearly spherical and distinct from the angular ore crystal.

## Design Considerations

- Use `<radialGradient>` (not linear) for the spherical sheen — this is key to looking like a pearl.
- The highlight should be off-center (upper-left) to simulate light reflection.
- Glow should be more subtle than other icons (pearl is elegant, not flashy).
- The shape is simple (circle) so the gradients do the heavy lifting for visual interest.
