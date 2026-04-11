# Task 06: Game Model — Replace gameMap with levels

## Summary
Replace `Game.gameMap: GameMap?` with `Game.levels: Map<int, GameMap>` to support multiple depth levels. Level 1 is generated at game creation; Level 2-3 are generated on first descent.

## Implementation Steps

1. **Update Game class** in `lib/domain/game/game.dart`:
   - Replace `@HiveField(4) GameMap? gameMap` with `@HiveField(4) Map<int, GameMap> levels`
   - Add helper: `GameMap? mapForLevel(int level) => levels[level]`
   - Add helper: `GameMap get currentMap => levels[1]!` (convenience for Level 1)
   - Update `Game.singlePlayer` factory to initialize `levels: {}`
   - Update constructor default: `this.levels = const {}`

2. **Update Game.singlePlayer** usage in `lib/presentation/screens/menu/new_game_screen.dart`:
   - Where `game.gameMap = result.map` → `game.levels[1] = result.map`

3. **Update all domain code** referencing `game.gameMap`:
   - `lib/domain/action/explore_action.dart`
   - `lib/domain/action/collect_treasure_action.dart`
   - `lib/domain/action/fight_monster_action.dart`
   - `lib/domain/map/exploration_resolver.dart`
   - `lib/domain/map/cell_eligibility_checker.dart`
   - Replace `game.gameMap!` → `game.levels[1]!` (or `game.mapForLevel(level)!` where level matters)

4. **Update all presentation code** referencing `game.gameMap`:
   - `lib/presentation/screens/game/game_screen.dart`
   - `lib/presentation/screens/game/game_screen_map_actions.dart`
   - `lib/presentation/widgets/map/game_map_view.dart`
   - Replace `game.gameMap!` → `game.levels[currentLevel]!` or `game.levels[1]!`

5. **Regenerate Hive adapters**

## Dependencies
- **Internal**: Tasks 01-05 (Player refactors complete)
- **External**: None

## Test Plan
- **File**: `test/domain/game/game_test.dart`
  - Verify `mapForLevel(1)` returns Level 1 map
  - Verify `mapForLevel(2)` returns null when no Level 2
- Run `flutter analyze` and `flutter test`

## Notes
- Changing `@HiveField(4)` type from `GameMap?` to `Map<int, GameMap>` breaks old saves. The try/catch in GameRepository handles this.
- At this stage, only Level 1 is populated. Level 2 generation happens in DescendAction (Task 15).
