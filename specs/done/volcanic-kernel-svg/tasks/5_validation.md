# Task 5: Validation and Final Checks

## Summary

Verify the SVG meets all SPEC acceptance criteria: line count, element counts, technical constraints, and Flutter compatibility.

## Implementation Steps

1. **Line count check**: Verify `volcanic_kernel.svg` has 150+ lines of SVG code.
   - If under 150, add detail: extra rock texture lines, more particles, additional crack lines, or a second set of plume wisps.

2. **Element count audit** (per SPEC acceptance criteria):
   - [ ] At least 2 lava flow paths down the flanks.
   - [ ] At least 1 side vent/fissure with glow.
   - [ ] At least 6 bubble elements (varying size and opacity).
   - [ ] At least 4 ember/particle elements near the crater.
   - [ ] At least 2 hydrothermal plume paths (curved, rising).
   - [ ] Crater glow uses radial gradient.

3. **Technical constraints audit**:
   - [ ] Single `<svg>` root with `xmlns` and `viewBox="0 0 64 64"`.
   - [ ] All gradient/filter IDs prefixed with `vk`.
   - [ ] No external references or embedded images.
   - [ ] No `<style>` blocks — all styling via attributes.
   - [ ] No animations.
   - [ ] Uses `linearGradient` and `radialGradient`.
   - [ ] Uses `feGaussianBlur` glow filter.

4. **Asymmetry check**: Visually confirm the composition is intentionally asymmetric — lava flows, side vents, and bubbles placed organically (not mirrored).

5. **Run `flutter analyze`**: Ensure no new warnings.

6. **Run `flutter test`**: Ensure no regressions.

7. **Fix any issues** found in steps 1-6.

## Dependencies

- Tasks 1-4 (all SVG content must be complete).

## Test Plan

- `flutter analyze` passes with no new warnings.
- `flutter test` passes with no regressions.
- `wc -l assets/icons/terrain/volcanic_kernel.svg` returns 150+.
- Manual grep confirms all `vk`-prefixed IDs and no `<style>` blocks.

## Notes

- If `flutter_svg` has issues with any SVG feature, simplify the problematic element while keeping the visual intent.
- The SVG should render correctly at both 24px and 64px — check that the silhouette + orange glow is readable even at small size.
