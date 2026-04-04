# Task 08 — Refactor GameScreen for turn resolution

## Summary

Replace the current `_nextTurn()` (which just increments `game.turn++`) with the full flow: show confirmation dialog → resolve turn → auto-save → show summary dialog.

## Implementation Steps

1. Open `lib/presentation/screens/game_screen.dart`
2. Add imports:
   ```dart
   import '../../domain/turn_resolver.dart';
   import '../widgets/turn_confirmation_dialog.dart';
   import '../widgets/turn_summary_dialog.dart';
   ```
3. Replace `_nextTurn()` with:
   ```dart
   Future<void> _nextTurn() async {
     final production = ProductionCalculator.fromBuildings(widget.game.buildings);

     final confirmed = await showTurnConfirmationDialog(
       context,
       production: production,
     );
     if (!confirmed || !mounted) return;

     final result = TurnResolver().resolve(widget.game);

     await widget.repository.save(widget.game);

     setState(() {});

     if (!mounted) return;
     await showTurnSummaryDialog(context, result: result);
   }
   ```
4. Verify that `GameBottomBar.onNextTurn` can accept a `Future<void> Function()` callback — it currently takes `VoidCallback`. Since `_nextTurn` is now async, it still satisfies `VoidCallback` (async void methods are valid VoidCallbacks in Dart).

## Dependencies

- Task 02 (`TurnResolver`)
- Task 04 (`showTurnConfirmationDialog`)
- Task 06 (`showTurnSummaryDialog`)
- Existing: `GameRepository`, `ProductionCalculator`

## Test Plan

- No tests in this task — see task 09.

## Notes

- The flow order is: confirm → resolve → save → setState → summary (per US-01 to US-04).
- `setState(() {})` refreshes the UI (resource bar, turn counter) before showing the summary.
- The `mounted` checks prevent calling `showDialog` after the widget has been disposed.
- GameScreen stays under 150 lines.
