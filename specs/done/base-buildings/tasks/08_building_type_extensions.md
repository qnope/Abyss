# Task 08 — BuildingType Extensions

## Summary

Create presentation extensions on `BuildingType` for display names, descriptions, icon paths, and colors. Follows the same pattern as `resource_type_extensions.dart`.

## Implementation Steps

1. Create `lib/presentation/extensions/building_type_extensions.dart`
2. Define two extensions:

### BuildingTypeColor

```dart
extension BuildingTypeColor on BuildingType {
  Color get color => switch (this) {
    BuildingType.headquarters => AbyssColors.biolumPurple,
  };
}
```

### BuildingTypeInfo

```dart
extension BuildingTypeInfo on BuildingType {
  String get displayName => switch (this) {
    BuildingType.headquarters => 'Quartier Général',
  };

  String get description => switch (this) {
    BuildingType.headquarters =>
      'Centre de commandement de votre base sous-marine. '
      'Son niveau détermine les capacités de votre colonie.',
  };

  String get iconPath => switch (this) {
    BuildingType.headquarters => 'assets/icons/buildings/headquarters.svg',
  };
}
```

3. Import `AbyssColors`, `BuildingType`, and `package:flutter/material.dart`

## Files

| Action | Path |
|--------|------|
| Create | `lib/presentation/extensions/building_type_extensions.dart` |

## Dependencies

- Task 01 (BuildingType enum)

## Test Plan

- No dedicated test file (trivial mappings, tested implicitly by widget tests in tasks 14-15)

## Notes

- Color for HQ is `biolumPurple` (#B388FF) matching the headquarters icon gradient
- Description comes directly from SPEC section 3
- `iconPath` points to the existing `assets/icons/buildings/headquarters.svg`
- Future building types will add entries to each switch expression
