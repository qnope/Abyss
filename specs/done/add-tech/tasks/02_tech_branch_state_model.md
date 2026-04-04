# Task 02 — TechBranchState Model

## Summary

Create the `TechBranchState` Hive model that stores the unlock status and research level (0–5) for a single tech branch.

## Implementation Steps

1. Create `lib/domain/tech_branch_state.dart`:
   ```dart
   @HiveType(typeId: 7)
   class TechBranchState extends HiveObject {
     @HiveField(0)
     final TechBranch branch;

     @HiveField(1)
     bool unlocked;

     @HiveField(2)
     int researchLevel; // 0 = none, 1–5 = researched nodes

     TechBranchState({
       required this.branch,
       this.unlocked = false,
       this.researchLevel = 0,
     });
   }
   ```
2. Run `dart run build_runner build --delete-conflicting-outputs` to generate `tech_branch_state.g.dart`.

## Files

| Action | Path |
|--------|------|
| Create | `lib/domain/tech_branch_state.dart` |
| Generated | `lib/domain/tech_branch_state.g.dart` |

## Dependencies

- Task 01 (`TechBranch` enum).

## Test Plan

- **File:** `test/domain/tech_branch_state_test.dart`
- Test default construction: `unlocked == false`, `researchLevel == 0`.
- Test construction with custom values.
- Covered in task 14.
