# Task 08: Create UnitIcon Widget

## Summary

Create a reusable `UnitIcon` widget that displays a unit's SVG icon, with optional greyscale filter for locked units. Mirrors `BuildingIcon`.

## Implementation Steps

### 1. Create `lib/presentation/widgets/unit_icon.dart`

Class `UnitIcon extends StatelessWidget`:

Props:
- `UnitType type`
- `double size` (default 40)
- `bool greyscale` (default false)

Build:
- Use `SvgPicture.asset(type.iconPath, width: size, height: size)`
- If `greyscale`: wrap in `ColorFiltered` with greyscale matrix (same as `BuildingIcon`)
- Import `unit_type_extensions.dart` for `iconPath`

## Dependencies

- Task 07 (UnitTypeExtensions for `iconPath`)
- Existing: `flutter_svg` package

## Test Plan

- **File**: `test/presentation/widgets/unit_icon_test.dart`
  - `UnitIcon(type: UnitType.scout)` uses asset path `assets/icons/units/scout.svg`
  - `UnitIcon(type: UnitType.domeBreaker)` uses `assets/icons/units/dome_breaker.svg`
  - `size` parameter sets width/height
  - `greyscale: true` wraps in `ColorFiltered`

## Notes

- Copy the greyscale `ColorMatrix` from `BuildingIcon` — same filter.
- Unit tests (not widget tests) for icon path mapping, matching `building_icon_test.dart` pattern.
