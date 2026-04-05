# Task 2: MapCell Model

## Summary

Create the `MapCell` Hive class (typeId 13) representing a single cell on the game map, holding terrain, content, fog, and optional bonus data.

## Implementation Steps

1. Create `lib/domain/map_cell.dart`:
   - `@HiveType(typeId: 13)`
   - `part 'map_cell.g.dart';`
   - Fields (all `final`):
     - `@HiveField(0) TerrainType terrain`
     - `@HiveField(1) CellContentType content`
     - `@HiveField(2) MonsterDifficulty? monsterDifficulty`
     - `@HiveField(3) bool isRevealed`
     - `@HiveField(4) ResourceType? bonusResourceType`
     - `@HiveField(5) int? bonusAmount`
   - Constructor with required `terrain`, defaults: `content = CellContentType.empty`, `isRevealed = false`, others null.
   - `MapCell copyWith(...)` method for immutable updates (needed for fog reveal and content placement).

## Dependencies

- Task 1 (enums: TerrainType, CellContentType, MonsterDifficulty)
- Existing `ResourceType` for `bonusResourceType`

## Test Plan

- File: `test/domain/map_cell_test.dart`
  - Default construction: content is empty, isRevealed is false, nullable fields are null
  - Full construction with all fields
  - copyWith preserves unchanged fields
  - copyWith overrides specified fields (e.g., `isRevealed: true`)

## Notes

- Keep under 50 lines. No business logic in the model.
