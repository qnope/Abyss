# Task 12: GameScreen Integration

## Summary

Replace the `TabPlaceholder` on the Carte tab (index 1) with the `GameMapView`, auto-generating the map if `gameMap` is null.

## Implementation Steps

1. Edit `lib/presentation/screens/game_screen.dart`:
   - Add imports for `GameMapView` and `MapGenerator`.
   - In `_buildTabContent()`, replace case `1`:
     ```dart
     1 => _buildMapTab(),
     ```
   - Add method `_buildMapTab()`:
     ```dart
     Widget _buildMapTab() {
       if (widget.game.gameMap == null) {
         _generateMap();
       }
       return GameMapView(gameMap: widget.game.gameMap!);
     }
     ```
   - Add method `_generateMap()`:
     ```dart
     void _generateMap() {
       widget.game.gameMap = MapGenerator.generate();
       widget.repository.save(widget.game);
     }
     ```
   - Remove `TabPlaceholder` import if no longer used elsewhere.

2. Verify the Carte tab label in `GameBottomBar` is correct (should already be "Carte" at index 1).

## Dependencies

- Task 5 (Hive adapters registered)
- Task 8 (MapGenerator)
- Task 11 (GameMapView)

## Test Plan

- File: `test/presentation/game_screen_map_test.dart`
  - Opening tab index 1 with gameMap == null → generates map, displays GameMapView
  - Opening tab index 1 with existing gameMap → displays GameMapView without regeneration
  - After generation, game.gameMap is not null

## Notes

- The generation is synchronous and fast (20×20 is tiny) — no loading indicator needed.
- Save is fire-and-forget (async but we don't await in build).
- The file stays under 150 lines since most logic is delegated.
