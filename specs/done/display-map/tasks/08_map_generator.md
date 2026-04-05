# Task 8: MapGenerator Orchestrator (Phase 3 + Coordination)

## Summary

Create `MapGenerator` — the top-level orchestrator that coordinates terrain generation (Phase 1), content placement (Phase 2), fog of war initialization (Phase 3), and returns a complete `GameMap`.

## Implementation Steps

1. Create `lib/domain/map_generator.dart`:
   - Class `MapGenerator` with a single static method:
     ```dart
     static GameMap generate({int? seed})
     ```
   - Algorithm:
     1. Create `Random` from seed (or `Random().nextInt(1 << 32)` if null).
     2. Determine base position: center (10, 10) offset by random (-2..2, -2..2).
     3. Call `TerrainGenerator.generate(width: 20, height: 20, random: random, baseX, baseY)`.
     4. Call `ContentPlacer.place(cells, width: 20, height: 20, baseX, baseY, random)`.
     5. Apply fog of war: for each cell, if Chebyshev distance from base ≤ 2, set `isRevealed = true` via copyWith.
     6. Set base cell content to `empty` (ensure no content on base).
     7. Construct and return `GameMap(width: 20, height: 20, cells: cells, playerBaseX: baseX, playerBaseY: baseY, seed: seed)`.

## Dependencies

- Task 3 (GameMap model)
- Task 6 (TerrainGenerator)
- Task 7 (ContentPlacer)

## Test Plan

- File: `test/domain/map_generator_test.dart`
  - Generated map is 20×20 (400 cells)
  - Player base is within 2 of center (10,10)
  - Base cell has content == empty
  - Exactly 25 cells are revealed (5×5 around base)
  - 375 cells have isRevealed == false
  - Revealed cells match Chebyshev distance ≤ 2 from base
  - Seed is saved and reproducible: `generate(seed: X)` twice → identical maps
  - Null seed generates a random seed (non-deterministic)
  - All terrain/content constraints from Tasks 6-7 hold transitively

## Notes

- This is the single public entry point for map creation.
- Keep under 80 lines — most logic is delegated to TerrainGenerator and ContentPlacer.
- The depth level field (`depthLevel`) can default to 1 (surface) — multi-level is out of scope.
