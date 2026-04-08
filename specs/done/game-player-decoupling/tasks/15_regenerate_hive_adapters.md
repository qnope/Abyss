# Task 15 — Regenerate Hive adapters and verify `GameRepository`

## Summary

All of the HiveType-bearing classes (`Player`, `Game`, `MapCell`, `GameMap`) have been restructured in tasks 02–05. This task runs `build_runner` to regenerate the `.g.dart` files, then verifies `GameRepository` still compiles and its auto-wipe-on-load behaviour still handles the breaking change.

## Implementation Steps

1. **Run code generation**
   - `dart run build_runner build --delete-conflicting-outputs`.
   - Verify the following files were regenerated:
     - `lib/domain/game/player.g.dart`
     - `lib/domain/game/game.g.dart`
     - `lib/domain/map/map_cell.g.dart`
     - `lib/domain/map/game_map.g.dart`
   - Inspect each file briefly to confirm the new HiveField indices match the source-code annotations.
2. **Verify `lib/data/game_repository.dart`**
   - Current code already wraps `Hive.openBox<Game>(_boxName)` in a try/catch that deletes the box on failure (see existing `initialize()`). Confirm it still compiles and still provides auto-wipe on a decode failure.
   - No behavioural change required unless new adapters need to be registered — add `Hive.registerAdapter(...)` calls only if a brand-new HiveType was introduced (none is expected from tasks 02–05).
3. **Add README note** about the intentional save break (SPEC §US-11):
   - Append a short paragraph to the top-level `README.md` under a "Migration" or "Notes" heading:
     > After the `game-player-decoupling` refactor (2026-04), pre-existing Hive saves are incompatible and will be deleted automatically on first launch. This is intentional while the game is in development.
   - If the repo has no `README.md`, create one with just this paragraph. Target: well under 150 lines.

## Dependencies

- Tasks 02, 03, 04, 05 (all HiveType shapes finalised).

## Test Plan

- `dart run build_runner build` exits successfully.
- A quick manual / scripted sanity check: construct a `Game.singlePlayer(Player.withBase(...))`, pass it through `GameRepository.save` + `loadAll`, confirm round-trip equality on key fields (player id, base coords, resources, revealedCells size, turn).
- Full Hive round-trip test lives in task 22.

## Notes

- If `build_runner` fails on the `Set<GridPosition>` serialisation, that's the signal to fall back to `List<GridPosition>` on the HiveField (per the escape hatch in task 02 notes) and expose `Set` via a getter. If so, update task 02's implementation accordingly and rerun this task.
- Do NOT manually edit `.g.dart` files. Only the generator should write them.
