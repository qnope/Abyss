# Task 13 — Update `ExplorationResolver` to operate per-player

## Summary

`ExplorationResolver.resolve` currently iterates `game.pendingExplorations` and flips `cell.isRevealed` on shared map cells. Rework it so that it iterates over **each player**, resolves that player's orders into that player's own `revealedCells`, and clears only that player's pending list.

## Implementation Steps

1. **Edit `lib/domain/map/exploration_resolver.dart`**
   - New signature: `static List<ExplorationResult> resolve(Game game)` — unchanged externally, but the internals iterate players.
   - Pseudocode:
     ```dart
     if (game.gameMap == null) return [];
     final map = game.gameMap!;
     final results = <ExplorationResult>[];
     for (final player in game.players.values) {
       if (player.pendingExplorations.isEmpty) continue;
       final explorerLevel =
           player.techBranches[TechBranch.explorer]?.researchLevel ?? 0;
       for (final order in player.pendingExplorations) {
         final positions = RevealAreaCalculator.cellsToReveal(
           targetX: order.target.x,
           targetY: order.target.y,
           explorerLevel: explorerLevel,
           mapWidth: map.width,
           mapHeight: map.height,
         );
         var newCells = 0;
         final notable = <CellContentType>[];
         for (final pos in positions) {
           if (player.revealedCells.add(pos)) {
             newCells++;
             final cell = map.cellAt(pos.x, pos.y);
             if (cell.content != CellContentType.empty) {
               notable.add(cell.content);
             }
           }
         }
         results.add(ExplorationResult(
           target: order.target,
           newCellsRevealed: newCells,
           notableContent: notable,
         ));
       }
       player.pendingExplorations.clear();
     }
     return results;
     ```
   - Remove all references to `cell.isRevealed` and `cell.copyWith(isRevealed: ...)`.
2. **Consider attaching the player id to `ExplorationResult`** — only if a test or the UI needs to know which player the result came from. If not obviously needed, skip (YAGNI).

## Dependencies

- Task 02 (Player owns `pendingExplorations` and `revealedCells`).
- Task 03 (cell no longer has `isRevealed`).
- Task 05 (Game exposes `players`).

## Test Plan

Test migration in task 21 (`exploration_resolver_test.dart`):

- A single-player game: resolving one order adds the expected positions to `player.revealedCells`.
- `player.pendingExplorations` is emptied after resolve.
- `notableContent` still reports non-empty cell contents of *newly* revealed cells (cells already in `revealedCells` are not re-counted — sanity case with two overlapping orders).
- Future-proof test with two synthetic `Player`s in the same `Game`: player A's reveal does not affect player B's `revealedCells`, and only player A's `pendingExplorations` is cleared.

## Notes

- `Set.add` returns `true` only when the element is newly added — ideal for counting freshly revealed cells.
- Do not touch `MapCell` in this task; fog-of-war state lives purely on the player now.
