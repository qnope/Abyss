# Task 24 — Update architecture docs for `domain/game` and `domain/map`

## Summary

Reflect the new responsibilities of `Player`, `Game`, `MapCell`, and `GameMap` in `specs/architecture/`. The architecture docs are the authoritative description of the shape of the code, so they must match the refactor.

## Implementation Steps

1. **`specs/architecture/domain/game/README.md`** (create if missing; existing subdirs indicate it may already have one)
   - Document `Player` as the owner of per-player state: id, name, baseX/baseY, resources, buildings, techBranches, units, recruitedUnitTypes, pendingExplorations, revealedCells.
   - Document `Game` as a container: `Map<String, Player> players`, `humanPlayerId`, `turn`, `createdAt`, `gameMap`.
   - Add a short mermaid diagram showing Game → Player → (resources, buildings, …).
2. **`specs/architecture/domain/map/README.md`** (create if missing)
   - Document `MapCell` fields post-refactor: terrain, content, monsterDifficulty, collectedBy. Note that fog of war is NOT stored here — it lives on `Player.revealedCells`.
   - Document `GameMap` without the base coordinates.
   - Document that `MapGenerator.generate()` returns a `MapGenerationResult` (map + baseX + baseY).
3. **`specs/architecture/domain/action/README.md`** (create if missing)
   - Note the new `Action` contract: `validate(Game, Player)` and `execute(Game, Player)`.
   - Emphasise that actions never read `Game` for per-player state; they read from the `Player` arg.
4. **`specs/architecture/README.md`** (top-level)
   - If the top-level doc mentions per-player state, update the paragraph.
   - Update the dependency flow sentence to mention that `Game` is a multi-player container.

## Dependencies

- Task 23 (stable, green codebase — docs should match reality, not a WIP state).

## Test Plan

- Docs manually reviewed for consistency with the code.
- Each updated README stays under 150 lines.
- `specs/architecture/domain/game/README.md` accurately describes the current `player.dart` and `game.dart`.

## Notes

- This is the dedicated "architecture docs update" task chosen during planning (rather than per-task inline updates).
- After this task, the project is ready for `/finalize-project game-player-decoupling`.
