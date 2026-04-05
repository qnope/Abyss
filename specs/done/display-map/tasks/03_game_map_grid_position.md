# Task 3: GameMap and GridPosition Models

## Summary

Create `GameMap` (typeId 14) and `GridPosition` (typeId 15) Hive classes. GameMap holds the full 20×20 grid, seed, and player base position. GridPosition is a simple (x, y) coordinate.

## Implementation Steps

1. Create `lib/domain/grid_position.dart`:
   - `@HiveType(typeId: 15)`
   - `part 'grid_position.g.dart';`
   - Fields: `@HiveField(0) int x`, `@HiveField(1) int y`
   - Constructor: `GridPosition({required this.x, required this.y})`
   - Override `==` and `hashCode` for value equality.

2. Create `lib/domain/game_map.dart`:
   - `@HiveType(typeId: 14)`
   - `part 'game_map.g.dart';`
   - Fields:
     - `@HiveField(0) int width`
     - `@HiveField(1) int height`
     - `@HiveField(2) List<MapCell> cells` (flat list, row-major order)
     - `@HiveField(3) int playerBaseX`
     - `@HiveField(4) int playerBaseY`
     - `@HiveField(5) int seed`
   - Helper method: `MapCell cellAt(int x, int y)` → `cells[y * width + x]`
   - Helper method: `void setCell(int x, int y, MapCell cell)` → `cells[y * width + x] = cell`

## Dependencies

- Task 2 (MapCell)

## Test Plan

- File: `test/domain/grid_position_test.dart`
  - Construction with x, y
  - Value equality: same (x,y) → equal, different → not equal
  - hashCode consistency

- File: `test/domain/game_map_test.dart`
  - Construction with 20×20 grid (400 cells)
  - `cellAt(x, y)` returns correct cell
  - `setCell(x, y, cell)` overwrites correct cell
  - Edge cases: (0,0), (19,19)

## Notes

- `cells` is a flat `List<MapCell>` (row-major) for Hive compatibility. Access is via `y * width + x`.
- GameMap is mutable (cells list) for generation efficiency — not a concern since it's only mutated during generation.
