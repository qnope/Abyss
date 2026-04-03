# Task 01 — Create ActionType enum

## Summary

Create the `ActionType` enum that identifies each kind of game action. For v1, only `upgradeBuilding` is needed. The enum uses an exhaustive switch pattern like `BuildingType` and `ResourceType`.

## Implementation Steps

1. Create `lib/domain/action_type.dart`
2. Define enum with a single value:
   ```dart
   enum ActionType {
     upgradeBuilding,
   }
   ```

## Dependencies

- None (leaf type, no imports needed)

## Test Plan

- No dedicated test file needed — this is a trivial enum with no logic.
- It will be exercised by `UpgradeBuildingAction` tests in task 04.

## Notes

- Follow the same style as `BuildingType` (`lib/domain/building_type.dart`).
- No Hive annotation needed — `ActionType` is not persisted.
