# Task 05 — UpgradeCheck Model + canUpgrade

## Summary

Create the `UpgradeCheck` result class and add a `canUpgrade` method to `BuildingCostCalculator` that returns a detailed result explaining whether an upgrade is possible and why not.

## Implementation Steps

1. Create `lib/domain/upgrade_check.dart`:

```dart
class UpgradeCheck {
  final bool canUpgrade;
  final bool isMaxLevel;
  final Map<ResourceType, int> missingResources;
  final Map<BuildingType, int> missingPrerequisites;

  const UpgradeCheck({
    required this.canUpgrade,
    this.isMaxLevel = false,
    this.missingResources = const {},
    this.missingPrerequisites = const {},
  });
}
```

2. Add `checkUpgrade` method to `BuildingCostCalculator`:

```dart
UpgradeCheck checkUpgrade({
  required BuildingType type,
  required int currentLevel,
  required Map<ResourceType, Resource> resources,
  required List<Building> allBuildings,
}) { ... }
```

Logic:
- If `currentLevel >= maxLevel(type)` → return `UpgradeCheck(canUpgrade: false, isMaxLevel: true)`
- Compute `upgradeCost` and compare each resource to available amount → collect `missingResources`
- Compute `prerequisites` and compare to actual building levels → collect `missingPrerequisites`
- `canUpgrade = missingResources.isEmpty && missingPrerequisites.isEmpty`

## Files

| Action | Path |
|--------|------|
| Create | `lib/domain/upgrade_check.dart` |
| Modify | `lib/domain/building_cost_calculator.dart` — add `checkUpgrade` method |

## Dependencies

- Task 02 (Building model — needed for `allBuildings` parameter)
- Task 04 (BuildingCostCalculator — adding method to it)

## Test Plan

- Tested in task 07

## Notes

- `missingResources` contains the *deficit* per resource (e.g., need 60 coral, have 20 → missing 40)
- `missingPrerequisites` contains the *required* level of each unmet prerequisite building
- The UI will use `isMaxLevel` to show "Niveau maximum atteint" and hide the button
- The UI will use `missingResources` to highlight insufficient resources in red
- The UI will use `missingPrerequisites` to show the blocking building name in red
