# Task 01 — Create CollectTreasureResult

## Summary

Introduce a `CollectTreasureResult` class extending `ActionResult` that carries the per-resource delta actually applied to the player stock. This lets the presentation layer display exactly what was gained after clamping at `maxStorage`.

## Implementation Steps

1. **Create `lib/domain/action/collect_treasure_result.dart`**

   ```dart
   import '../resource/resource_type.dart';
   import 'action_result.dart';

   class CollectTreasureResult extends ActionResult {
     final Map<ResourceType, int> deltas;

     const CollectTreasureResult.success(this.deltas) : super.success();

     const CollectTreasureResult.failure(String reason)
         : deltas = const {},
           super.failure(reason);
   }
   ```

2. **Verify constructor compatibility**
   - The base `ActionResult` constructors are already `const` — confirm both `success()` and `failure(reason)` are visible to the subclass.
   - `deltas` must be non-null (use `const {}` for failure).

## Dependencies

- None (pure addition).

## Test Plan

- **File:** `test/domain/action/collect_treasure_result_test.dart`
- Test cases:
  - `CollectTreasureResult.success({...})` exposes `isSuccess == true` and the provided `deltas` map.
  - `CollectTreasureResult.failure('reason')` exposes `isSuccess == false`, `reason == 'reason'`, and an empty `deltas` map.
  - A `CollectTreasureResult` is assignable to a variable of type `ActionResult` (compile-time check via assignment).

## Notes

- Subclassing `ActionResult` is the chosen approach. The presentation layer downcasts to `CollectTreasureResult` when handling collect outcomes.
- Keep this file under 30 lines.
