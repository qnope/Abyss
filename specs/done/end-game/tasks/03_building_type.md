# Task 3: Add `volcanicKernel` building type

## Summary

Add `volcanicKernel` to the `BuildingType` enum and include it in `PlayerDefaults.buildings()`.

## Implementation Steps

### 1. Edit `lib/domain/building/building_type.dart`

Add new enum value:

```dart
@HiveField(10) volcanicKernel,
```

### 2. Edit `lib/domain/game/player_defaults.dart`

In `buildings()`, add:

```dart
BuildingType.volcanicKernel: Building(type: BuildingType.volcanicKernel, level: 0),
```

### 3. Fix exhaustive switch statements

Search for `switch` on `BuildingType` across the codebase. Key files that need a new case:
- `lib/domain/building/building_cost_calculator.dart` — `upgradeCost()`, `maxLevel()`, `prerequisites()`, `requiredCapturedBase()` (add placeholder returns, will be completed in tasks 7-8)
- `lib/domain/building/building_deactivator.dart` — `_priority` list (will be completed in task 10)
- `lib/presentation/extensions/building_type_extensions.dart` — all 3 extensions (will be completed in task 10)

For now, add minimal placeholder cases:
- `upgradeCost` → return `{}`
- `maxLevel` → return `10`
- `prerequisites` → return `{}`
- `requiredCapturedBase` → return `null`

## Dependencies

- None (independent of tasks 1, 2)

## Test Plan

- **File**: `test/domain/building/building_type_test.dart`
- Verify `BuildingType.volcanicKernel` exists
- Verify `BuildingType.values` contains 11 values
- Verify `PlayerDefaults.buildings()` contains `volcanicKernel` at level 0

## Notes

- `build_runner` will be run in task 4
