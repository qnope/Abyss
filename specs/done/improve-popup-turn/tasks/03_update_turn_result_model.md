# Task 3: Update TurnResult and TurnResourceChange models

## Summary

Extend `TurnResourceChange` with `beforeAmount` and `afterAmount` fields, and extend `TurnResult` with turn numbers and recruitment tracking.

## Implementation Steps

### 1. Update `TurnResourceChange`

**File**: `lib/domain/turn_result.dart`

Add two new required fields:

```dart
class TurnResourceChange {
  final ResourceType type;
  final int produced;       // net production (production - maintenance)
  final bool wasCapped;
  final int beforeAmount;   // resource amount before turn resolution
  final int afterAmount;    // resource amount after turn resolution

  const TurnResourceChange({
    required this.type,
    required this.produced,
    required this.wasCapped,
    required this.beforeAmount,
    required this.afterAmount,
  });
}
```

### 2. Update `TurnResult`

**File**: `lib/domain/turn_result.dart` (same file)

Add turn tracking and recruitment flag:

```dart
class TurnResult {
  final List<TurnResourceChange> changes;
  final int previousTurn;          // turn number before resolution
  final int newTurn;               // turn number after resolution
  final bool hadRecruitedUnits;    // true if player had recruited units last turn

  const TurnResult({
    required this.changes,
    required this.previousTurn,
    required this.newTurn,
    required this.hadRecruitedUnits,
  });
}
```

### 3. Fix all compilation errors

After updating the model, the following files will have compilation errors due to missing required fields. Fix each call site:

- `lib/domain/turn_resolver.dart` — will be fully updated in Task 4, but for now add placeholder values so it compiles
- `test/domain/turn_resolver_test.dart` — tests will be updated in Task 4
- `test/presentation/widgets/turn_summary_dialog_test.dart` — tests will be updated in Task 6, but fix constructors now

For each `TurnResourceChange(...)` constructor call, add `beforeAmount: 0, afterAmount: 0` as placeholders.
For each `TurnResult(...)` constructor call, add `previousTurn: 0, newTurn: 0, hadRecruitedUnits: false` as placeholders.

## Dependencies

- None (model-only change)

## Test Plan

- Run: `flutter analyze` — verify no compilation errors
- Run: `flutter test` — verify all existing tests still pass with placeholder values
- The new fields will be meaningfully tested when TurnResolver is updated (Task 4)

## Notes

- `produced` now represents **net** production (building production minus maintenance), though at this stage TurnResolver hasn't been updated yet
- `beforeAmount` and `afterAmount` allow the UI to show progression: `Name before (+net) → after`
- `hadRecruitedUnits` drives the "Recrutement disponible" message in the summary dialog
- `previousTurn` / `newTurn` allow both dialogs to show "Tour X → Tour X+1"
