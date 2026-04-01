# Task 09 — BuildingIcon Widget

## Summary

Create a reusable `BuildingIcon` widget that renders building SVG icons with optional greyscale mode for unbuilt buildings (level 0).

## Implementation Steps

1. Create `lib/presentation/widgets/building_icon.dart`
2. Define the widget:

```dart
class BuildingIcon extends StatelessWidget {
  final BuildingType type;
  final double size;
  final bool greyscale;

  const BuildingIcon({
    super.key,
    required this.type,
    this.size = 24,
    this.greyscale = false,
  });
}
```

3. Build method:
   - Use `SvgPicture.asset()` with the path from `type.iconPath` (via BuildingTypeInfo extension)
   - Set `width` and `height` to `size`
   - When `greyscale` is true, apply `ColorFilter.mode(AbyssColors.disabled, BlendMode.srcIn)` to render the SVG in the disabled grey color
   - When `greyscale` is false, render normally (no color filter)

## Files

| Action | Path |
|--------|------|
| Create | `lib/presentation/widgets/building_icon.dart` |

## Dependencies

- Task 01 (BuildingType enum)
- Task 08 (BuildingTypeInfo extension for `iconPath`)

## Test Plan

- File: `test/presentation/widgets/building_icon_test.dart`
- Test cases:
  - Renders SvgPicture widget
  - Uses correct asset path for headquarters
  - Default size is 24
  - Custom size is applied
  - Greyscale applies a ColorFilter
  - Non-greyscale has no ColorFilter
- Use `mockSvgAssets()` from test helpers (same pattern as `resource_icon_test.dart`)

## Notes

- Follows the same structure as `ResourceIcon` (`lib/presentation/widgets/resource_icon.dart`)
- `BlendMode.srcIn` replaces the SVG colors with the filter color, creating a monochrome silhouette effect for the "not built" state
- `AbyssColors.disabled` (#3A5070) is the existing disabled color in the theme
