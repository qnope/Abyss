# Task 08 — EndTurnAction

## Summary

Introduce `EndTurnAction` so that ending a turn goes through the uniform `Action` + `ActionExecutor` pipeline. The action wraps `TurnResolver` and returns a new `EndTurnActionResult` carrying the human player's `TurnResult`. `makeHistoryEntry` returns a `TurnEndEntry` built from that result. This replaces the current direct `TurnResolver().resolve(game)` call site in `game_screen.dart`.

## Implementation Steps

1. Add `endTurn` to `ActionType` (`lib/domain/action/action_type.dart`).
2. Create `lib/domain/action/end_turn_action_result.dart`:
   - `class EndTurnActionResult extends ActionResult` with:
     - `final TurnResult? turnResult`
     - Named constructors `success({required this.turnResult}) : super.success()` and `const failure(String reason) : turnResult = null, super.failure();`.
3. Create `lib/domain/action/end_turn_action.dart`:
   - `class EndTurnAction extends Action`.
   - `type => ActionType.endTurn`.
   - `description => 'Terminer le tour'`.
   - `validate(game, player)` → always success for now (no pre-turn checks required by the current ruleset). Keep open for future.
   - `execute(game, player)`:
     - Calls `TurnResolver().resolve(game)` to get a `TurnResult`.
     - Returns `EndTurnActionResult.success(turnResult: result)`.
   - `makeHistoryEntry(game, player, result, turn)`:
     - Casts `result` to `EndTurnActionResult`.
     - Calls `TurnEndEntryFactory.fromTurnResult(result.turnResult!)` with `turn - 1` (the turn that just ended — `TurnResolver` already incremented `game.turn`).
4. Update `lib/presentation/screens/game/game_screen.dart` `_nextTurn()`:
   - Replace `final result = TurnResolver().resolve(widget.game);` with
     ```dart
     final action = EndTurnAction();
     final actionResult =
         ActionExecutor().execute(action, widget.game, _human) as EndTurnActionResult;
     final result = actionResult.turnResult!;
     ```
   - Everything else (`save`, `setState`, `showTurnSummaryDialog`) stays the same.
5. The `ActionExecutor` from task 07 already appends the `TurnEndEntry` via `makeHistoryEntry` after a successful execute.

## Dependencies

- Blocks: task 11 (integration tests), task 12 (UI integration).
- Blocked by: tasks 03 (TurnEndEntry), 05, 06, 07.

## Test Plan

- `test/domain/action/end_turn_action_test.dart`:
  - Run `EndTurnAction` via `ActionExecutor` on a `Game` with known production, assert:
    - `game.turn` advanced by 1.
    - `player.historyEntries.last` is a `TurnEndEntry`.
    - That `TurnEndEntry.turn == previousTurn` (the turn that ended, not the new turn).
    - That `TurnEndEntry.changes`, `deactivatedBuildings`, `lostUnits` match the `TurnResult`.
- `test/presentation/game_screen_end_turn_test.dart` (widget test):
  - Build a `GameScreen`, tap "Next Turn", confirm the dialog, then verify the game was saved and a `TurnEndEntry` was added.

## Notes

- Resist the temptation to also record per-player turn summaries for AI players; the spec is single-player only.
- `EndTurnAction.execute` intentionally only returns the human's turn result, matching the current `TurnResolver` contract.
- Keep both new files under 150 lines.
