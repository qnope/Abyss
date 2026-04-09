# Task 07 — ActionExecutor Records History on Success

## Summary

Update `ActionExecutor` so that, after a successful action execution, it asks the action for a `HistoryEntry` and appends it to the player's history via `Player.addHistoryEntry`. Failed validations still short-circuit with no entry, as required by US-5.

## Implementation Steps

1. Edit `lib/domain/action/action_executor.dart`:
   ```dart
   class ActionExecutor {
     ActionResult execute(Action action, Game game, Player player) {
       final validation = action.validate(game, player);
       if (!validation.isSuccess) return validation;
       final result = action.execute(game, player);
       if (result.isSuccess) {
         final entry = action.makeHistoryEntry(game, player, result, game.turn);
         if (entry != null) player.addHistoryEntry(entry);
       }
       return result;
     }
   }
   ```
2. Verify the executor is the single entry point for every caller (UI layer, tests). If any call site bypasses it, route it through the executor first (separate refactor task if needed — flag and stop).
3. Do NOT record entries when the inner `execute` returns a failure (e.g. `FightMonsterResult.failure`).

## Dependencies

- Blocks: task 08 (turn-end wiring), task 11 (integration tests).
- Blocked by: tasks 05, 06.

## Test Plan

- `test/domain/action/action_executor_history_test.dart`:
  - Successful `UpgradeBuildingAction` → `player.historyEntries` gains one `BuildingEntry` with current `game.turn`.
  - Failed validation (no resources) → `player.historyEntries` stays empty and the returned `ActionResult` has `isSuccess == false`.
  - Failed execute (e.g. `FightMonsterAction` with 0 units) → `player.historyEntries` stays empty.
  - 105 successful actions in a row → `player.historyEntries.length == 100`, oldest 5 are dropped (FIFO).

## Notes

- Keep `action_executor.dart` under 150 lines (trivial).
- Do not touch turn-end flow here — that's the next task.
