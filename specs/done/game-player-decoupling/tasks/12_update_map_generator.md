# Task 12 — Update `MapGenerator` to emit base coordinates separately and drop per-cell fog seeding

## Summary

`MapGenerator.generate` currently stamps `playerBaseX`/`playerBaseY` onto `GameMap` and calls `_applyFogOfWar` to flip `cell.isRevealed` on the starting vision cells. Both responsibilities move out of `MapGenerator`: base coordinates are returned alongside the map, and initial reveal is computed by `Player.withBase` (task 02).

## Implementation Steps

1. **Edit `lib/domain/map/map_generator.dart`**
   - Remove the `_applyFogOfWar` helper entirely and its call site. Delete the `_revealRadius` constant.
   - Remove `playerBaseX: baseX, playerBaseY: baseY` from the `GameMap(...)` constructor call (they no longer exist — see task 04).
   - Change the return type from `GameMap` to a small record or dedicated struct so the caller receives both the map and the base coordinates:
     ```dart
     class MapGenerationResult {
       final GameMap map;
       final int baseX;
       final int baseY;
       const MapGenerationResult({
         required this.map,
         required this.baseX,
         required this.baseY,
       });
     }

     static MapGenerationResult generate({int? seed}) { ... }
     ```
     Place `MapGenerationResult` in its own file `lib/domain/map/map_generation_result.dart` if `map_generator.dart` grows over 150 lines. A Dart record `({GameMap map, int baseX, int baseY})` is also acceptable if the caller signature stays clean.
2. **Keep `_clearBaseContent`** — the base cell still needs to be emptied of content.

## Dependencies

- Task 04 (`GameMap` no longer has `playerBaseX`/`playerBaseY`).

## Test Plan

Add / update `test/domain/map/map_generator_test.dart` (covered in task 19):

- `generate(seed: 42)` returns a `MapGenerationResult` with a 20×20 map.
- The returned `baseX`, `baseY` are within the map bounds.
- The cell at `(baseX, baseY)` has `content == CellContentType.empty`.
- Deterministic with a fixed seed.
- No cell has `isRevealed` set (field no longer exists — sanity check that map cells no longer track fog).

## Notes

- The caller that builds a fresh `Game` (task 16, in `new_game_screen.dart`) will call `MapGenerator.generate()`, then construct a `Player.withBase(...)` using the returned `baseX`/`baseY`, then build the `Game` with that player and the returned `map`.
- Because `Player.withBase` computes `revealedCells` itself (task 02), `MapGenerator` no longer needs to know about fog of war at all.
