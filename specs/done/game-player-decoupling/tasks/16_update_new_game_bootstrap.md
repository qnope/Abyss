# Task 16 — Update new-game bootstrap to create a `Player` with id/base/initial reveal

## Summary

Today `new_game_screen.dart` does `Player(name: ...); Game(player: player);` and the map is lazily generated later in `game_screen_map_actions.buildMapTab`. Because the player needs its `baseX`/`baseY` and initial `revealedCells` at construction time (task 02), map generation must move into the new-game flow.

## Implementation Steps

1. **Edit `lib/presentation/screens/menu/new_game_screen.dart`**
   - In `_submit`, replace the current `Player`/`Game` construction with:
     ```dart
     final generation = MapGenerator.generate();
     final player = Player.withBase(
       name: _controller.text.trim(),
       baseX: generation.baseX,
       baseY: generation.baseY,
       mapWidth: generation.map.width,
       mapHeight: generation.map.height,
     );
     final game = Game.singlePlayer(player)..gameMap = generation.map;
     await widget.repository.save(game);
     ```
   - Add the necessary imports (`MapGenerator`, new `MapGenerationResult` if used, updated `Game`).
2. **Edit `lib/presentation/screens/game/game_screen_map_actions.dart`**
   - Remove the lazy `if (game.gameMap == null) { game.gameMap = MapGenerator.generate(); ... }` block — the map is always set from the bootstrap now.
   - Any references to `game.gameMap!.playerBaseX` / `playerBaseY` migrate to `game.humanPlayer.baseX` / `baseY` (the base-tap branch). The `ExploreAction` / `CollectTreasureAction` calls get a `game.humanPlayer` arg (see task 17).

## Dependencies

- Task 02 (`Player.withBase`).
- Task 05 (`Game.singlePlayer`).
- Task 12 (`MapGenerator.generate` returns a `MapGenerationResult`).
- Task 15 (generated adapters exist so `repository.save` works).

## Test Plan

Manual + presentation tests (task 22):

- Launching "New game" creates a game whose `humanPlayer.revealedCells` is non-empty.
- `game.gameMap` is not null immediately after save.
- `humanPlayer.baseX` / `baseY` match the generated base.
- Existing new-game flow tests (if any in `test/presentation/screens/menu/`) still pass.

## Notes

- Because the map is now created up front, there is no first-tab lazy generation anymore — `GameScreen` can rely on `game.gameMap` being non-null.
- Keep file lengths under 150 lines.
