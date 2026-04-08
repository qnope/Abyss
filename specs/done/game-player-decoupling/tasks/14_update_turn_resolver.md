# Task 14 — Update `TurnResolver` to iterate players

## Summary

`TurnResolver` currently reads every per-player field directly from `Game`. Refactor it so that it iterates over `game.players.values` and applies the production / consumption / losses pipeline **once per player**. Each player's `TurnResult` is aggregated so the UI sees a single result for the human player (what it displays today).

## Implementation Steps

1. **Edit `lib/domain/turn/turn_resolver.dart`**
   - Split the monolithic `resolve(Game game)` into two methods:
     - `TurnResult resolve(Game game)`: iterates `game.players.values`, calls `_resolveForPlayer(player, game)` for each, and returns the result for `game.humanPlayer` specifically. Increments `game.turn` and runs exploration resolution *after* the per-player loop (since `ExplorationResolver.resolve(game)` already iterates players itself — task 13).
     - `TurnResult _resolveForPlayer(Player player, Game game)`: contains the old logic but reads/writes `player.resources`, `player.buildings`, `player.units`, `player.techBranches`, `player.recruitedUnitTypes`.
   - The existing ordering (production → energy deactivation → algae losses → resource application) is preserved; only the field accesses change.
   - `game.recruitedUnitTypes.clear()` becomes `player.recruitedUnitTypes.clear()` and happens inside the per-player method.
   - `game.turn++` happens **once** in the outer method, not per player.
2. **Check file length** — if `turn_resolver.dart` exceeds 150 lines after the split, move `_resolveForPlayer` into a new file `lib/domain/turn/player_turn_resolver.dart` and keep `TurnResolver` as a thin orchestrator.

## Dependencies

- Task 02 (Player owns all the state TurnResolver reads).
- Task 05 (Game exposes `players` and `humanPlayer`).
- Task 13 (`ExplorationResolver.resolve(game)` is already per-player).

## Test Plan

Test migration in task 21 (`turn_resolver_test.dart`):

- Single-player case: identical behaviour to today (production applied, recruited-unit list cleared, turn incremented).
- Two-player case (future-proof): player A's resources change, player B's resources are unchanged when B has empty queues.
- `game.turn` is incremented exactly once per `resolve`, even with multiple players.
- Exploration resolution still fires once.
- `hadRecruitedUnits` in the returned `TurnResult` reflects the **human player** specifically (match current UI expectation).

## Notes

- Be careful with the `BuildingDeactivator` call — it mutates the building map in place. Keep that behaviour, just swap `game.buildings` → `player.buildings`.
- The `TurnResult` for non-human players is currently discarded. A later project (AI factions) can choose whether to collect them; for now we only return the human's.
