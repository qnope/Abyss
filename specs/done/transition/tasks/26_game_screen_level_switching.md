# Task 26: Integrate Level Switching in GameScreen

## Summary
Wire the `LevelSelector` widget into the map tab of `GameScreen`. Add `currentLevel` state. Map display switches based on selected level.

## Implementation Steps

1. **Add state** to `GameScreen` (or its state class):
   - `int _currentLevel = 1`
   - Compute `unlockedLevels` from `game.levels.keys.toSet()`
   - Compute `capturedCounts` by scanning each level's map for captured transition bases

2. **Insert LevelSelector** in `lib/presentation/screens/game/game_screen.dart`:
   - Place above `GameMapView` in the map tab (tab index 1)
   - Pass `currentLevel`, `unlockedLevels`, `capturedCounts`, `onLevelSelected`
   - On level change: `setState(() => _currentLevel = level)`

3. **Update GameMapView usage**:
   - Pass `game.levels[_currentLevel]!` instead of `game.levels[1]!`
   - Pass `player.revealedCellsSetOnLevel(_currentLevel)` for fog
   - Pass `player.unitsOnLevel(_currentLevel)` for army context

4. **Update map action handlers** in `game_screen_map_actions.dart`:
   - Pass `_currentLevel` to all map-related actions (explore, collect, fight)
   - Transition base taps: open `TransitionBaseSheet`

5. **ResourceBar**: no change (resources are global, always visible)

## Dependencies
- **Internal**: Task 21 (LevelSelector widget), Task 06 (Game.levels), Task 05 (presentation updated)
- **External**: GameScreen, GameMapView (existing)

## Test Plan
- Manual/widget test: verify level selector appears on map tab
- Verify switching levels changes the displayed map
- Verify Level 1 actions still work after integration
- Run `flutter analyze`

## Notes
- At this stage, only Level 1 is unlocked at game start. Level 2+ becomes available after descent.
- The army tab should also be level-aware: show units for `_currentLevel`. Update if needed.
