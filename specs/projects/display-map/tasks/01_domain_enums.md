# Task 1: Domain Enums (TerrainType, CellContentType, MonsterDifficulty)

## Summary

Create the three Hive-annotated enums needed by the map system: `TerrainType` (typeId 10), `CellContentType` (typeId 11), and `MonsterDifficulty` (typeId 12).

## Implementation Steps

1. Create `lib/domain/terrain_type.dart`:
   - Hive enum with `@HiveType(typeId: 10)`
   - Values: `reef` (0), `plain` (1), `rock` (2), `fault` (3)
   - `part 'terrain_type.g.dart';`

2. Create `lib/domain/cell_content_type.dart`:
   - Hive enum with `@HiveType(typeId: 11)`
   - Values: `empty` (0), `resourceBonus` (1), `ruins` (2), `monsterLair` (3)
   - `part 'cell_content_type.g.dart';`

3. Create `lib/domain/monster_difficulty.dart`:
   - Hive enum with `@HiveType(typeId: 12)`
   - Values: `easy` (0), `medium` (1), `hard` (2)
   - `part 'monster_difficulty.g.dart';`

## Dependencies

- None (first task)

## Test Plan

- File: `test/domain/terrain_type_test.dart`
  - Verify all 4 TerrainType values exist
  - Verify typeId is 10

- File: `test/domain/cell_content_type_test.dart`
  - Verify all 4 CellContentType values exist
  - Verify typeId is 11

- File: `test/domain/monster_difficulty_test.dart`
  - Verify all 3 MonsterDifficulty values exist
  - Verify typeId is 12

## Notes

- Follow exact pattern of existing `resource_type.dart` for Hive annotation style.
- Do NOT run `build_runner` yet — that will happen in Task 4 after all models are created.
