# Task 8: Add volcanic kernel prerequisites and upgrade check

## Summary

Add HQ 10 prerequisite for the volcanic kernel building and require the volcanic kernel cell to be captured before the building can be constructed.

## Implementation Steps

### 1. Edit `lib/domain/building/building_cost_calculator.dart`

Update `prerequisites()` for `volcanicKernel`:
```dart
BuildingType.volcanicKernel => {BuildingType.headquarters: 10},
```

HQ 10 is required for ALL levels of the volcanic kernel building (1 through 10).

Add a new method:
```dart
bool requiresCapturedKernel(BuildingType type) {
  return type == BuildingType.volcanicKernel;
}
```

Update `checkUpgrade()` signature — add parameter:
```dart
bool isVolcanicKernelCaptured = false,
```

In `checkUpgrade()`, after the `missingBase` calculation, add:
```dart
final bool missingKernel = requiresCapturedKernel(type) && !isVolcanicKernelCaptured;
```

Update the `canUpgrade` condition:
```dart
canUpgrade: missingResources.isEmpty &&
    missingPrereqs.isEmpty &&
    missingBase == null &&
    !missingKernel,
```

Pass `missingCapturedKernel: missingKernel` to `UpgradeCheck`.

### 2. Edit `lib/domain/building/upgrade_check.dart`

Add field:
```dart
final bool missingCapturedKernel;
```

Update constructor:
```dart
this.missingCapturedKernel = false,
```

## Dependencies

- Task 3: `BuildingType.volcanicKernel` must exist
- Task 7: costs must be defined

## Test Plan

- **File**: `test/domain/building/building_cost_calculator_test.dart` (add tests)
- Test: `prerequisites(BuildingType.volcanicKernel, 1)` returns `{headquarters: 10}`
- Test: `prerequisites(BuildingType.volcanicKernel, 5)` returns `{headquarters: 10}`
- Test: `requiresCapturedKernel(BuildingType.volcanicKernel)` returns `true`
- Test: `requiresCapturedKernel(BuildingType.headquarters)` returns `false`
- Test: `checkUpgrade()` with `isVolcanicKernelCaptured: false` returns `canUpgrade: false` with `missingCapturedKernel: true`
- Test: `checkUpgrade()` with `isVolcanicKernelCaptured: true` and HQ 10 and sufficient resources returns `canUpgrade: true`
- Test: `checkUpgrade()` with `isVolcanicKernelCaptured: true` but HQ < 10 returns `canUpgrade: false` with `missingPrerequisites`
