# Task 19 — Domain tests for `Player`, `Game`, `MapCell`, `GameMap`, `MapGenerator`

## Summary

Add or migrate the unit tests that cover the new shape of the core domain types. These tests do not touch Hive — they exercise the pure Dart classes built in tasks 02–05 and 12.

## Implementation Steps

1. **Create/update `test/domain/game/player_test.dart`**
   - Default constructor assigns a unique UUID when `id` is omitted (assert two fresh players have distinct ids).
   - Explicit `id` is preserved.
   - Defaults for `resources`, `buildings`, `techBranches`, `units` match the previous `Game.default*` factories (copy assertions from any pre-existing `game_test.dart`).
   - `Player.withBase(baseX: 10, baseY: 10, mapWidth: 20, mapHeight: 20)` populates `revealedCells` exactly with `RevealAreaCalculator.cellsToReveal(targetX: 10, targetY: 10, explorerLevel: 0, mapWidth: 20, mapHeight: 20).toSet()`.
   - Two independently-constructed players mutate independently (modify `resources[algae].amount` on A, assert B unchanged).
2. **Create/update `test/domain/game/game_test.dart`**
   - `Game.singlePlayer(player)`:
     - `humanPlayer` returns that player.
     - `players` contains exactly one entry keyed by `player.id`.
     - `turn == 1`, `createdAt` is set.
     - `gameMap == null` initially (the new-game flow attaches it separately).
   - Constructing with two players at once — `players.length == 2`, `humanPlayer` returns the correct one by id.
3. **Create/update `test/domain/map/map_cell_test.dart`**
   - Default `collectedBy == null`, `isCollected == false`.
   - `copyWith(collectedBy: 'uuid-a')` sets the value.
   - `copyWith()` without `collectedBy` preserves the existing value.
   - `copyWith`-with-null-clear (using whatever sentinel pattern task 03 chose) clears it.
4. **Create/update `test/domain/map/game_map_test.dart`**
   - `GameMap` no longer has `playerBaseX`/`playerBaseY` (compilation check — just construct without them).
   - `cellAt` / `setCell` continue to behave correctly.
5. **Create/update `test/domain/map/map_generator_test.dart`**
   - `MapGenerator.generate(seed: 42)` is deterministic.
   - Returns a result with `baseX`, `baseY` inside bounds.
   - Base cell content is `CellContentType.empty`.
   - No cell has any fog-of-war state left on it (the field no longer exists — smoke-test that cells are still well-formed).

## Dependencies

- Tasks 02, 03, 04, 05, 12.
- Task 15 (not required for the tests to *compile*, but running them end-to-end needs the regenerated adapters).

## Test Plan

These *are* the tests. Validation: `flutter test test/domain/` passes cleanly.

## Notes

- Delete any obsolete assertions on `game.resources`/`game.buildings`/etc. from the existing `test/domain/game/game_test.dart` (if it exists) and move them into `player_test.dart`.
- Keep each test file under 150 lines — split by concern (construction vs. defaults vs. isolation) if needed.
