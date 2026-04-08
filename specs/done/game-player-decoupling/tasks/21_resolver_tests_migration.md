# Task 21 — Update `ExplorationResolver` and `TurnResolver` tests

## Summary

Migrate the resolver tests to the per-player model and add future-proofing cases with a second synthetic player so the multi-player behaviour (even though we ship single-player) is locked in.

## Implementation Steps

1. **`test/domain/map/exploration_resolver_test.dart`**
   - Build a `Game.singlePlayer(player)` with `player.pendingExplorations` seeded and `player.revealedCells` starting at the initial reveal.
   - Assertions:
     - After `resolve(game)`, `player.revealedCells` contains all positions returned by `RevealAreaCalculator`.
     - `player.pendingExplorations.isEmpty` afterwards.
     - `newCellsRevealed` reported in `ExplorationResult` matches the count of freshly added cells (cells already revealed are not re-counted).
   - Add a multi-player case:
     - Two players in the same `Game`, each with their own `pendingExplorations` targeted at a different cell.
     - After `resolve`, each player's `revealedCells` contains only their own reveal.
     - Other player's `pendingExplorations` is untouched if its list was empty, and cleared if it had orders.
2. **`test/domain/turn/turn_resolver_test.dart`**
   - Rewrite the existing assertions to read from `game.humanPlayer.*` instead of `game.*`.
   - Keep the production/consumption/deactivation/algae-loss scenarios intact.
   - Assert `game.turn` increments exactly once.
   - Add a multi-player case (two fresh players, default resources): verify that `resolve` mutates each player's resources independently.
   - Assert `game.humanPlayer.recruitedUnitTypes.isEmpty` after resolve (cleared).

## Dependencies

- Tasks 13, 14 (resolver implementations are migrated).
- Task 19 (Player test factories are available).

## Test Plan

`flutter test test/domain/map/exploration_resolver_test.dart test/domain/turn/turn_resolver_test.dart` passes.

## Notes

- Construct test players cheaply via the bare `Player(id: 'a', name: 'A', baseX: 5, baseY: 5)` constructor — `Player.withBase` is only needed when you care about initial revealed cells.
- For the turn resolver, a helper to pre-seed a player with desired resource amounts and building levels will make the tests much shorter.
