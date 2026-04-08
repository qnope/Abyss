# Task 22 — Update presentation tests (`ResourceBar`, `MapCellWidget`, `GameMapView`) and add Hive round-trip

## Summary

Migrate widget tests for `ResourceBar`, `MapCellWidget`, and `GameMapView` to the new API. Add a Hive round-trip integration test to lock in that saving then loading a fresh `Game` via `GameRepository` preserves the human player's full state.

## Implementation Steps

1. **`test/presentation/widgets/resource/resource_bar_test.dart`**
   - Existing tests already pass `resources: <ResourceType, Resource>`. No API change on `ResourceBar` itself — only the call sites changed. A smoke test that `ResourceBar(resources: player.resources, ...)` still renders correctly is enough. Update any setup code that built a `Game` for the test to now build a `Player`.
2. **`test/presentation/widgets/map/map_cell_widget_test.dart`**
   - Build tests with the new `MapCellWidget` parameters (`isRevealed: bool`, `isCollectedByOther: bool` — or however task 18 parameterised it).
   - Cases:
     - Not revealed → fog overlay present.
     - Revealed, `collectedBy == null` → icon at full opacity.
     - Revealed, `collectedBy == humanPlayerId` → icon at 0.3 opacity.
     - Revealed, `collectedBy == 'other-uuid'` → icon at 0.3 opacity.
     - `isBase: true` → base SVG renders instead of content.
3. **`test/presentation/widgets/map/game_map_view_test.dart`** (create if absent)
   - Pump a `GameMapView` wrapped in a `MaterialApp`, pass a small 3×3 map plus a `revealedCells` set, assert that the expected cells render fog vs. content.
   - Assert that the base cell uses the passed `baseX`/`baseY` (look for the player-base SVG).
4. **`test/data/game_repository_roundtrip_test.dart`** (new file)
   - Initialise Hive with a temp path, register adapters (or call `GameRepository.initialize`).
   - Build `Game.singlePlayer(Player.withBase(...))` with a non-default set of resource amounts and a non-empty `revealedCells`.
   - Save via `GameRepository`, re-open the box, re-load, assert equality on key fields:
     - `humanPlayer.id`, `name`, `baseX`, `baseY`.
     - Resource amounts per type.
     - `revealedCells` set equality.
     - `turn`, `createdAt`.
5. **Fix the broken-save auto-wipe test** (if one exists in `test/data/`)
   - If there is an existing test for the auto-wipe behaviour, make sure it still passes; otherwise add a minimal test that writes a stray file into the box path and asserts `initialize()` cleans it up.

## Dependencies

- Tasks 15, 16, 17, 18 (widgets and repository in their final shape).
- Task 19 (Player construction helpers reusable).

## Test Plan

`flutter test` passes in its entirety after this task.

## Notes

- `test/helpers/` already exists; add any shared test helpers there rather than duplicating builders.
- The round-trip test doubles as a smoke-test for the Hive adapter regeneration from task 15.
