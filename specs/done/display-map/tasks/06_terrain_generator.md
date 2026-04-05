# Task 6: Terrain Generator (Phase 1)

## Summary

Create `TerrainGenerator` — a stateless class that implements Phase 1 of map generation: base placement, neighbor safety, random terrain distribution, and connectivity validation.

## Implementation Steps

1. Create `lib/domain/terrain_generator.dart`:
   - Class `TerrainGenerator` with a single static method:
     ```dart
     static List<MapCell> generate({
       required int width,
       required int height,
       required Random random,
       required int baseX,
       required int baseY,
     })
     ```
   - Algorithm:
     1. Create `width * height` cells, all default (reef terrain).
     2. Set base cell terrain to `plain`.
     3. For each of the 8 neighbors of (baseX, baseY) that are in-bounds: randomly assign `reef` or `plain`.
     4. For all remaining cells: weighted random — reef 40%, plain 30%, rock 15%, fault 15%.
     5. Call `_ensureConnectivity(cells, width, height, baseX, baseY)`.
     6. Return the cells list.

   - Private helper `_ensureConnectivity`:
     - For each of the 4 map edges (top, bottom, left, right):
       - BFS/flood-fill from base using non-rock cells.
       - If any edge is unreachable, find shortest path of rock cells to convert to plain.
       - Repeat until all 4 edges are reachable.

## Dependencies

- Task 1 (TerrainType enum)
- Task 2 (MapCell model)

## Test Plan

- File: `test/domain/terrain_generator_test.dart`
  - Base cell is plain
  - 8 neighbors of base are reef or plain (never rock/fault)
  - Terrain distribution roughly matches targets (±10% tolerance over 400 cells)
  - All 4 edges reachable from base via non-rock path (BFS verification)
  - Same seed + same base → same terrain output
  - Different seeds → different terrain output

## Notes

- Uses `dart:math Random` seeded for reproducibility.
- The connectivity fix is critical: without it, the player might be walled off.
- Keep under 150 lines. BFS helper can be a simple private function.
