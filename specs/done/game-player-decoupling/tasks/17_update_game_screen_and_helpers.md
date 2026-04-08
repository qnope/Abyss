# Task 17 — Migrate `GameScreen` and sub-helpers to read/write via `game.humanPlayer`

## Summary

`GameScreen` and its helper files in `lib/presentation/screens/game/` currently read `game.resources`, `game.buildings`, `game.units`, `game.techBranches`, `game.pendingExplorations`, etc. Migrate every such access to `game.humanPlayer.<field>`. Also update calls to `ActionExecutor().execute(action, game)` to pass the human player.

## Implementation Steps

1. **Edit `lib/presentation/screens/game/game_screen.dart`**
   - Replace `widget.game.buildings`, `widget.game.resources`, `widget.game.units`, `widget.game.techBranches`, `widget.game.pendingExplorations` with `widget.game.humanPlayer.*`.
   - Helper getters such as:
     ```dart
     Player get _human => widget.game.humanPlayer;
     ```
     keep the body readable.
2. **Edit `lib/presentation/screens/game/game_screen_actions.dart`**
   - Every `ActionExecutor().execute(action, game)` call → `ActionExecutor().execute(action, game, game.humanPlayer)`.
   - Every `game.resources`, `game.buildings`, etc. read → `game.humanPlayer.*`.
3. **Edit `lib/presentation/screens/game/game_screen_map_actions.dart`**
   - `_showCellAction`:
     - `if (!cell.isRevealed)` → `if (!game.humanPlayer.revealedCells.contains(GridPosition(x: x, y: y)))`.
     - The base-cell detection: `if (x == game.humanPlayer.baseX && y == game.humanPlayer.baseY)`.
     - `cell.isCollected` — keep (the getter still exists).
   - `_showExplorationFlow`:
     - `scoutCount` read from `game.humanPlayer.units[UnitType.scout]?.count ?? 0`.
     - `explorerLevel` read from `game.humanPlayer.techBranches[TechBranch.explorer]?.researchLevel ?? 0`.
     - `ActionExecutor().execute(action, game, game.humanPlayer)`.
   - `_collectTreasure`:
     - `ActionExecutor().execute(action, game, game.humanPlayer)`.
   - `buildMapTab`:
     - `pendingTargets` → `game.humanPlayer.pendingExplorations.map(...).toSet()`.
4. **Edit `lib/presentation/screens/game/game_screen_tech_actions.dart`** and **`game_screen_turn_helpers.dart`**
   - Same mechanical migration: `game.<field>` → `game.humanPlayer.<field>`.
   - `computeConsumption(game)` / `computeBuildingsToDeactivate(game, production)` / `computeUnitsToLose(game, deactivated)` helpers — if they read per-player state, update their signatures to accept a `Player` instead of a `Game`. Prefer changing the helpers themselves over littering `game.humanPlayer` at each call site.
5. **Check file lengths** — after migration, ensure each file still fits under 150 lines.

## Dependencies

- Tasks 02, 05 (Player and Game shapes).
- Task 06 (ActionExecutor takes a Player).
- Tasks 07–11 (concrete actions compile with new signature).
- Task 16 (new-game bootstrap provides a human player with base + revealed cells, so these reads never hit `null`).

## Test Plan

Widget / integration sanity — covered in task 22:

- `GameScreen` builds without throwing for a freshly-constructed single-player `Game`.
- Tapping a revealed treasure cell triggers the collect flow, which debits `humanPlayer.resources`.
- Tapping a base cell shows the "Votre base" sheet.
- Tapping an unrevealed cell shows the exploration sheet (if eligible).
- Ending a turn still works and re-renders with updated resources.

## Notes

- This is the widest mechanical change in the project. Do it in one focused pass: grep for `widget.game.` and `game.` accesses inside `lib/presentation/screens/game/` and migrate each.
- `cell_info_sheet.dart`, `exploration_sheet.dart`, `treasure_sheet.dart`, `monster_lair_sheet.dart` should NOT need changes — they take primitives (coords, counts, costs), not a `Game`.
