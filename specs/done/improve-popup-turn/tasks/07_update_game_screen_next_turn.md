# Task 7: Update GameScreen._nextTurn() flow

## Summary

Wire the updated confirmation and summary dialogs with the new data requirements in the `_nextTurn()` method.

## Implementation Steps

### 1. Update `_nextTurn()` method

**File**: `lib/presentation/screens/game_screen.dart`

Replace the current `_nextTurn()` implementation:

```dart
Future<void> _nextTurn() async {
  final production = ProductionCalculator.fromBuildings(
    widget.game.buildings,
    techBranches: widget.game.techBranches,
  );
  final maintenance = MaintenanceCalculator.fromUnits(widget.game.units);

  // Compute net production for confirmation dialog
  final netProduction = <ResourceType, int>{};
  final allTypes = {...production.keys, ...maintenance.keys};
  for (final type in allTypes) {
    netProduction[type] = (production[type] ?? 0) - (maintenance[type] ?? 0);
  }

  final confirmed = await showTurnConfirmationDialog(
    context,
    currentTurn: widget.game.turn,
    resources: widget.game.resources,
    netProduction: netProduction,
  );
  if (!confirmed || !mounted) return;

  final result = TurnResolver().resolve(widget.game);
  await widget.repository.save(widget.game);
  setState(() {});
  if (mounted) await showTurnSummaryDialog(context, result: result);
}
```

### 2. Add imports

**File**: `lib/presentation/screens/game_screen.dart`

Add:
```dart
import '../../domain/maintenance_calculator.dart';
import '../../domain/resource_type.dart';
```

(`resource_type.dart` may already be imported transitively — check first)

### 3. Remove unused import

If `production_calculator.dart` was only used to pass production to the old dialog, verify it's still needed (it is — for computing production before net calculation). Remove any imports that are no longer used.

## Dependencies

- **Task 2**: `MaintenanceCalculator` must exist
- **Task 4**: Updated `TurnResolver` must exist
- **Task 5**: Updated `showTurnConfirmationDialog` signature must exist
- **Task 6**: Updated `showTurnSummaryDialog` (no signature change, uses updated `TurnResult`)

## Test Plan

- Run: `flutter analyze` — verify no compilation errors
- Run: `flutter test` — verify all tests pass
- Manual verification: the full turn flow should work end-to-end

## Notes

- The net production computation is duplicated between GameScreen and TurnResolver. This is intentional: the confirmation dialog needs the prediction *before* resolution, while TurnResolver computes the actual values. They should produce the same results.
- Keep the file under 150 lines (currently at 164 lines — the method size stays roughly the same)
- The `production` variable computed in `build()` for `ResourceBar` is separate and unchanged
