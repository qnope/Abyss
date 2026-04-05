# Task 4: Add gameMap to Game + Run build_runner

## Summary

Add the nullable `gameMap` field (HiveField 8) to the `Game` model and run `build_runner` to generate all `.g.dart` files for the 6 new types + updated Game.

## Implementation Steps

1. Edit `lib/domain/game.dart`:
   - Add import: `import 'game_map.dart';`
   - Add field after `recruitedUnitTypes`:
     ```dart
     @HiveField(8)
     GameMap? gameMap;
     ```
   - Add `this.gameMap` to constructor (nullable, no default).

2. Run `dart run build_runner build --delete-conflicting-outputs` to generate:
   - `terrain_type.g.dart`
   - `cell_content_type.g.dart`
   - `monster_difficulty.g.dart`
   - `map_cell.g.dart`
   - `game_map.g.dart`
   - `grid_position.g.dart`
   - Updated `game.g.dart`

3. Verify all `.g.dart` files are generated without errors.

## Dependencies

- Task 1 (enums)
- Task 2 (MapCell)
- Task 3 (GameMap, GridPosition)

## Test Plan

- File: `test/domain/game_test.dart` (update existing):
  - New Game has `gameMap == null` by default
  - Game can be constructed with a gameMap

## Notes

- HiveField 8 is the next available index on Game (0-7 are taken).
- `gameMap` must be nullable for backward compatibility with existing saves.
- `build_runner` generates Hive adapters for all annotated types.
