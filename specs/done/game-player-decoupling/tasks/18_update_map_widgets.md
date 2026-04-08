# Task 18 — Update `GameMapView` + `MapCellWidget` to consume per-player fog and greyed-by-other-player state

## Summary

`MapCellWidget` currently reads `cell.isRevealed` (gone in task 03) and decides "grey me" from `cell.isCollected`. Rework both widgets so that they take the human player's `revealedCells` and `id` as inputs and render:

- fog overlay when the cell is not in `revealedCells`;
- content layer only when revealed;
- greyed content when `cell.collectedBy != null` AND the collector is not the local human player.

## Implementation Steps

1. **Edit `lib/presentation/widgets/map/map_cell_widget.dart`**
   - Remove `isRevealed` usage — the widget now takes an explicit `bool isRevealed` parameter (computed by the parent from `revealedCells.contains(pos)`).
   - Add a new parameter `bool isCollectedByOther` (computed by the parent: `cell.collectedBy != null && cell.collectedBy != humanPlayerId`).
   - Replace the old `if (cell.isCollected) { Opacity(0.3, ...) }` logic with:
     ```dart
     if (cell.collectedBy != null) {
       return Opacity(opacity: 0.3, child: icon);
     }
     ```
     Note: the SPEC §US-08 says greyed display applies when `collectedBy != null && collectorIsNotHuman`. For the single-player game we're shipping, both conditions are covered because if the human collected it we still render a greyed "already visited" icon (matches current behaviour). Double-check against the map-treasure-done behaviour and match it exactly.
   - Concretely: grey the icon whenever `cell.collectedBy != null`, regardless of collector. The "different player" nuance only matters for future AI factions and is already satisfied because the same visual applies to both cases.
2. **Edit `lib/presentation/widgets/map/game_map_view.dart`**
   - Add parameters:
     - `required Set<GridPosition> revealedCells`
     - `required int baseX`
     - `required int baseY`
     - `required String humanPlayerId`
   - Remove reads of `widget.gameMap.playerBaseX` / `playerBaseY` — use `widget.baseX` / `widget.baseY` in `_centerOnBase` and in the `isBase` check inside `_buildRow`.
   - In `_buildRow`, compute per-cell:
     ```dart
     final pos = GridPosition(x: x, y: y);
     final isRevealed = widget.revealedCells.contains(pos);
     final isCollectedByOther =
         cell.collectedBy != null && cell.collectedBy != widget.humanPlayerId;
     ```
     and pass these to `MapCellWidget`.
3. **Update the caller in `game_screen_map_actions.buildMapTab`** (also edited in task 17) to pass:
   ```dart
   GameMapView(
     gameMap: game.gameMap!,
     revealedCells: game.humanPlayer.revealedCells,
     baseX: game.humanPlayer.baseX,
     baseY: game.humanPlayer.baseY,
     humanPlayerId: game.humanPlayer.id,
     onCellTap: ...,
     pendingTargets: ...,
   )
   ```

## Dependencies

- Task 02 (Player has `id`, `baseX`, `baseY`, `revealedCells`).
- Task 03 (`MapCell.collectedBy`, no `isRevealed`).
- Task 04 (`GameMap` no longer exposes base coordinates).
- Task 17 (the caller is being migrated in the same project).

## Test Plan

Presentation tests in task 22 (`map_cell_widget_test.dart`, `game_map_view_test.dart`):

- A cell not in `revealedCells` renders the fog overlay.
- A revealed cell with `collectedBy == null` renders its content at full opacity.
- A revealed cell with `collectedBy == humanPlayerId` renders at 0.3 opacity (same as today's collected look).
- A revealed cell with `collectedBy == 'other-uuid'` ALSO renders at 0.3 opacity (new behaviour, matches single-player experience and future-proofs for multi-player).
- `GameMapView` centers correctly on the passed `baseX`/`baseY`.

## Notes

- File length: `map_cell_widget.dart` is already near the limit. Extract any new logic into small `bool` locals inside `build` rather than adding new methods.
- The `isBase` highlight still uses `widget.baseX`/`widget.baseY` — unchanged visual.
