# Task 08 — Migrate `ExploreAction` to per-player state

## Summary

Update `ExploreAction` so that the scout count is read from the calling `Player`, the scout is debited on the player's unit map, and the `ExplorationOrder` is queued on `player.pendingExplorations`.

## Implementation Steps

1. **Edit `lib/domain/action/explore_action.dart`**
   - Update imports: add `../game/player.dart`.
   - Change `validate(Game game)` → `validate(Game game, Player player)`:
     - Null-check `game.gameMap` (unchanged).
     - Replace `game.units[UnitType.scout]?.count ?? 0` with `player.units[UnitType.scout]?.count ?? 0`.
     - Keep `CellEligibilityChecker.isEligible(game.gameMap!, targetX, targetY)` unchanged.
   - Change `execute(Game game)` → `execute(Game game, Player player)`:
     - Re-run `validate(game, player)`.
     - Decrement `player.units[UnitType.scout]!.count`.
     - Add the `ExplorationOrder` to `player.pendingExplorations`.

## Dependencies

- Task 02 (Player owns units / pendingExplorations).
- Task 06 (Action signature accepts Player).
- Task 05 (Game no longer has units / pendingExplorations).

## Test Plan

Test migration happens in task 20. Cases to cover:

- Scout count is read from the passed `Player`, not from any shared `Game` state.
- On success, scout count decreases on the *caller's* `Player` only.
- `ExplorationOrder` is queued on `player.pendingExplorations`, not on another player's queue.
- Validation fails if caller's scouts are zero.

## Notes

- No visible behaviour change for the single-player game.
- `CellEligibilityChecker` still reads from `GameMap` directly — no migration needed. (It checks terrain/content, not revealed state.)
