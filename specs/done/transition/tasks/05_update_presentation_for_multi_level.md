# Task 05: Update Presentation for Multi-Level Fields

## Summary
Update all screens, widgets, and helpers that reference `player.units` or `player.revealedCellsList` to use the new per-level accessors.

## Implementation Steps

1. **GameScreen helpers** (`lib/presentation/screens/game/`):
   - `game_screen_actions.dart`: replace `player.units` → `player.unitsOnLevel(currentLevel)` or `player.unitsOnLevel(1)` where appropriate
   - `game_screen_map_actions.dart`: update fog-of-war checks to use `player.revealedCellsSetOnLevel(currentLevel)`
   - `game_screen_fight_actions.dart`: update unit references for combat on current level

2. **ArmyListView** (`lib/presentation/widgets/unit/army_list_view.dart`):
   - Accept a `level` parameter (default 1) or receive pre-filtered units
   - Display units for the current level

3. **ArmySelectionScreen** (`lib/presentation/screens/fight/army_selection_screen.dart`):
   - Read units from the level where the fight happens

4. **GameMapView** (`lib/presentation/widgets/map/game_map_view.dart`):
   - Use `player.revealedCellsSetOnLevel(level)` for fog rendering

5. **UnitCard / UnitDetailSheet** (`lib/presentation/widgets/unit/`):
   - If they read `player.units` directly, update references

6. **ResourceBar** (`lib/presentation/widgets/resource/resource_bar.dart`):
   - No change needed (resources are global)

7. **Search all presentation files** for `player.units` and `revealedCellsList` references

## Dependencies
- **Internal**: Task 02 (Player model), Task 03-04 (domain updated)
- **External**: None

## Test Plan
- Run `flutter analyze` — zero warnings
- Manual verification: game screen renders correctly with Level 1 units
- All existing widget tests pass

## Notes
- At this stage, the game still only has Level 1. Multi-level presentation is wired in Tasks 22-28.
- The `currentLevel` concept will be introduced in GameScreen in Task 27.
