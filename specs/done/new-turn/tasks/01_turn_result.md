# Task 01 — Create TurnResult data classes

## Summary

Create two lightweight data classes: `TurnResourceChange` (per-resource turn outcome) and `TurnResult` (aggregated turn outcome). These carry the information needed by the post-turn summary dialog.

## Implementation Steps

1. Create `lib/domain/turn_result.dart`
2. Define `TurnResourceChange`:
   ```dart
   class TurnResourceChange {
     final ResourceType type;
     final int produced;
     final bool wasCapped;

     const TurnResourceChange({
       required this.type,
       required this.produced,
       required this.wasCapped,
     });
   }
   ```
3. Define `TurnResult`:
   ```dart
   class TurnResult {
     final List<TurnResourceChange> changes;

     const TurnResult({required this.changes});
   }
   ```

## Dependencies

- Existing: `ResourceType` (`lib/domain/resource_type.dart`)

## Test Plan

- No dedicated tests — these are plain data holders with no logic.
- Exercised by `TurnResolver` tests (task 03).

## Notes

- No Hive annotation — not persisted.
- Keep file under 25 lines.
- Follow the same immutable style as `ActionResult`.
