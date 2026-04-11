# Task 03 — Validate Rendering and Tests

## Summary

Verify that both new SVG icons render correctly in the Flutter app and that no regressions are introduced.

## Dependencies

- Task 01 (descent_module.svg must exist)
- Task 02 (pressure_capsule.svg must exist)

## Implementation Steps

### Step 1 — Run flutter analyze

```bash
flutter analyze
```

Verify: no new warnings or errors related to the SVG files or building icon code.

### Step 2 — Run flutter test

```bash
flutter test
```

Verify: all existing tests pass, including `test/presentation/widgets/building/building_icon_test.dart`.

### Step 3 — SVG structural validation

For each new SVG file, verify:
- Single `<svg>` root with `xmlns="http://www.w3.org/2000/svg"` and `viewBox="0 0 64 64"`
- All gradient IDs are prefixed (`dm` for descent_module, `pc` for pressure_capsule)
- No `<style>` blocks present
- No external references or embedded images
- Line count is 150+ for each file
- `feGaussianBlur` filter is present

### Step 4 — Symmetry spot-check

For each SVG, verify Y-axis symmetry by checking that:
- Elements at x-offset from center have matching elements at opposite x-offset
- Centered elements use x=32 or cx=32

## Test Plan

- `flutter analyze` passes cleanly
- `flutter test` passes — 0 failures
- Both SVG files meet all structural constraints from SPEC.md

## Notes

- The existing `building_icon_test.dart` tests use `BuildingType.headquarters` only, so the new SVGs won't be directly unit-tested. The validation here is structural + no-regression.
- If `flutter_svg` fails to parse either file at runtime, the error would appear during widget rendering, not in unit tests. The structural checks in Step 3 catch common issues.
