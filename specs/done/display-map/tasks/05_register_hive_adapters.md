# Task 5: Register Hive Adapters in GameRepository

## Summary

Register the 6 new Hive adapters (typeIds 10–15) in `GameRepository.initialize()` so the map models can be persisted.

## Implementation Steps

1. Edit `lib/data/game_repository.dart`:
   - Add imports:
     ```dart
     import '../domain/terrain_type.dart';
     import '../domain/cell_content_type.dart';
     import '../domain/monster_difficulty.dart';
     import '../domain/map_cell.dart';
     import '../domain/game_map.dart';
     import '../domain/grid_position.dart';
     ```
   - Add 6 adapter registrations in `initialize()`, before `GameAdapter()`:
     ```dart
     Hive.registerAdapter(TerrainTypeAdapter());
     Hive.registerAdapter(CellContentTypeAdapter());
     Hive.registerAdapter(MonsterDifficultyAdapter());
     Hive.registerAdapter(MapCellAdapter());
     Hive.registerAdapter(GameMapAdapter());
     Hive.registerAdapter(GridPositionAdapter());
     ```

## Dependencies

- Task 4 (build_runner must have generated the adapters)

## Test Plan

- No dedicated tests needed — adapter registration is verified implicitly by integration tests in Task 13.
- Verify `flutter analyze` passes after this change.

## Notes

- Order of registration does not matter for Hive, but place them before `GameAdapter()` for readability (dependencies first).
- The file will remain well under 150 lines.
