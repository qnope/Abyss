# Task 01 — TechBranch Enum

## Summary

Create the `TechBranch` Hive enum representing the 3 technology branches: military, resources, explorer.

## Implementation Steps

1. Create `lib/domain/tech_branch.dart`:
   ```dart
   @HiveType(typeId: 6)
   enum TechBranch {
     @HiveField(0) military,
     @HiveField(1) resources,
     @HiveField(2) explorer,
   }
   ```
2. Run `dart run build_runner build --delete-conflicting-outputs` to generate `tech_branch.g.dart`.

## Files

| Action | Path |
|--------|------|
| Create | `lib/domain/tech_branch.dart` |
| Generated | `lib/domain/tech_branch.g.dart` |

## Dependencies

- None (leaf task).

## Test Plan

- No dedicated test file needed — the enum is validated through `TechBranchState` and `TechCostCalculator` tests (tasks 14).
- Verify the `.g.dart` file is generated without errors.
