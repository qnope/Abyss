# Task 07 — Migrate `CollectTreasureAction` to per-player state

## Summary

Update `CollectTreasureAction` so that it reads/writes resources on the `Player` argument, checks `player.revealedCells` (not `cell.isRevealed`), refuses to run if `cell.collectedBy != null`, and stamps `cell.collectedBy = player.id` on success.

## Implementation Steps

1. **Edit `lib/domain/action/collect_treasure_action.dart`**
   - Update imports: add `../game/player.dart` and `../map/grid_position.dart`.
   - Change `validate(Game game)` → `validate(Game game, Player player)`:
     - Null-check `game.gameMap` — unchanged message.
     - Replace `if (!cell.isRevealed)` with:
       ```dart
       if (!player.revealedCells.contains(GridPosition(x: targetX, y: targetY))) {
         return const CollectTreasureResult.failure('Case non révélée');
       }
       ```
     - Replace `if (cell.isCollected)` by `if (cell.collectedBy != null)` with the same failure message.
     - Keep the content-type guard unchanged.
   - Change `execute(Game game)` → `execute(Game game, Player player)`:
     - Re-run `validate(game, player)`.
     - Replace every `game.resources[...]` read/write with `player.resources[...]`.
     - On success, `cell.copyWith(collectedBy: player.id)` (or the sentinel-aware copyWith from task 03) instead of `copyWith(isCollected: true)`.
   - Update `_addResource` helper to take a `Player` instead of a `Game`.
2. **Verify file length** stays under 150 lines.

## Dependencies

- Task 02 (Player.resources / Player.revealedCells exist).
- Task 03 (MapCell.collectedBy exists).
- Task 06 (Action signature accepts Player).
- Task 05 (Game has no resources field — reads must come from Player).

## Test Plan

Test migration happens in task 20 (`collect_treasure_action_*_test.dart`). Cases to cover:

- Success path credits the *given player's* resources (not some shared Game state).
- `collectedBy` is stamped with the exact UUID of the calling player.
- Validation fails with "Déjà collecté" when `collectedBy` is already set — regardless of which player is calling.
- Validation fails with "Case non révélée" when the cell is not in `player.revealedCells`, even if another player has revealed it (future-proofing — still worth a test).
- Second player with the same UUID cannot double-collect (edge case).

## Notes

- `GridPosition` equality / hashing must work properly for `revealedCells.contains(...)` — verify the existing implementation has `==`/`hashCode` overrides. If not, add them as part of this task (one-line override using `@HiveField` indices).
- The existing `CollectTreasureAction` uses `Random` for deltas; keep the seed-injectable constructor as-is.
