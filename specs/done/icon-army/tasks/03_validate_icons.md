# Task 03 - Validate Both SVG Icons

## Summary

Validate that both `barracks.svg` and `laboratory.svg` are structurally correct, flutter_svg-compatible, visually consistent with existing icons, and readable at all target sizes.

## Validation Steps

### Step 1 — Structural validation

For each file (`barracks.svg`, `laboratory.svg`), verify:
- [ ] File exists at the correct path (`assets/icons/buildings/`)
- [ ] `viewBox="0 0 64 64"`
- [ ] `<defs>` block contains a `<linearGradient>` and a `<filter>` with `feGaussianBlur stdDeviation="3"`
- [ ] All visual content is inside a single `<g filter="url(#...Glow)">` group
- [ ] Gradient direction is bottom-to-top (`x1="0" y1="1" x2="0" y2="0"`)

### Step 2 — flutter_svg compatibility

For each file, verify:
- [ ] No `<style>` or CSS attributes
- [ ] No `<use>` elements
- [ ] No `<text>` elements
- [ ] No `<clipPath>` or `<mask>` (unless simple)
- [ ] Only basic SVG elements: `svg`, `defs`, `linearGradient`, `stop`, `filter`, `feGaussianBlur`, `feMerge`, `feMergeNode`, `g`, `path`, `polygon`, `polyline`, `rect`, `circle`, `ellipse`, `line`

### Step 3 — Color palette distinction

- [ ] Barracks uses orange/amber tones, visibly distinct from Solar Panel yellow (#FF8F00/#FFD740)
- [ ] Laboratory uses teal/cyan-green tones, visibly distinct from Algae Farm green (#2E7D32/#69F0AE)
- [ ] Neither icon reuses the exact gradient colors of any existing icon

### Step 4 — Consistency with existing icons

- [ ] Both icons include a base platform element
- [ ] Both use the same SVG conventions (comments, gradient naming, filter naming)
- [ ] Complexity is comparable to existing icons (~40-80 lines of SVG content inside `<g>`)

### Step 5 — Run flutter analyze

```bash
flutter analyze
```

Ensure no warnings or errors related to assets.

### Step 6 — Run existing tests

```bash
flutter test
```

Ensure no regressions. The existing `building_icon_test.dart` tests may reference building types — new icons should not break anything since they are not yet integrated into the code (scope is SVG only).

## Dependencies

- **Blocked by**: Task 01 (barracks.svg), Task 02 (laboratory.svg)

## Test Plan

This task IS the test plan. All checks above must pass.

## Notes

- Scope is SVG files only — no code integration is expected per SPEC.md.
- If flutter_svg issues are found, fix the SVG directly (remove incompatible elements).
