# Task 08 — TechBranch Presentation Extensions

## Summary

Create display extensions for `TechBranch`: color, display name, description, icon path.

## Implementation Steps

### 1. Create `lib/presentation/extensions/tech_branch_extensions.dart`

```dart
extension TechBranchColor on TechBranch {
  Color get color => switch (this) {
    TechBranch.military => AbyssColors.biolumPink,
    TechBranch.resources => AbyssColors.algaeGreen,
    TechBranch.explorer => AbyssColors.biolumCyan,
  };
}

extension TechBranchInfo on TechBranch {
  String get displayName => switch (this) {
    TechBranch.military => 'Militaire',
    TechBranch.resources => 'Ressources',
    TechBranch.explorer => 'Explorateur',
  };

  String get description => switch (this) {
    TechBranch.military =>
      'Améliore l\'attaque et la défense de toutes les unités.',
    TechBranch.resources =>
      'Améliore la production de toutes les ressources.',
    TechBranch.explorer =>
      'Améliore la portée d\'exploration de la carte.',
  };

  String get iconPath => switch (this) {
    TechBranch.military => 'assets/icons/buildings/barracks.svg',
    TechBranch.resources => 'assets/icons/resources/algae.svg',
    TechBranch.explorer => 'assets/icons/units/scout.svg',
  };
}
```

Imports: `TechBranch`, `AbyssColors`, `flutter/material.dart`.

### Note on icon paths

The spec references `barracks.svg`, `algae.svg`, `scout.svg`. These exist in the project:
- `assets/icons/buildings/barracks.svg` — Military
- `assets/icons/resources/algae.svg` — Resources
- `assets/icons/units/scout.svg` — Explorer

## Files

| Action | Path |
|--------|------|
| Create | `lib/presentation/extensions/tech_branch_extensions.dart` |

## Dependencies

- Task 01 (`TechBranch` enum).

## Test Plan

- **File:** `test/presentation/extensions/tech_branch_extensions_test.dart`
- Test all 3 branches return non-null values for `color`, `displayName`, `description`, `iconPath`.
- Covered in task 15.
