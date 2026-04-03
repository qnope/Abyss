# Task 02 — Create ActionResult class

## Summary

Create the `ActionResult` class that represents the outcome of an action execution or validation. It holds a boolean success flag and an optional failure reason string.

## Implementation Steps

1. Create `lib/domain/action_result.dart`
2. Define immutable class:
   ```dart
   class ActionResult {
     final bool isSuccess;
     final String? reason;

     const ActionResult._({required this.isSuccess, this.reason});

     const factory ActionResult.success() = ActionResult._;
     // Use: ActionResult.success() → isSuccess=true, reason=null

     factory ActionResult.failure(String reason) =>
       ActionResult._(isSuccess: false, reason: reason);
   }
   ```
3. Use factory constructors `ActionResult.success()` and `ActionResult.failure(reason)` for clarity.

## Dependencies

- None

## Test Plan

- **File**: `test/domain/action_result_test.dart`
- **Test cases**:
  - `ActionResult.success()` has `isSuccess == true` and `reason == null`
  - `ActionResult.failure('msg')` has `isSuccess == false` and `reason == 'msg'`

## Notes

- Keep it simple: no Hive annotation (not persisted).
- Follow the same immutable pattern as `UpgradeCheck` (`lib/domain/upgrade_check.dart`).
