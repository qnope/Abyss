# Task 27: Wire Transition Action Handlers in GameScreen

## Summary
Add handler methods in `GameScreen` for the three transition actions: assault, descend, and send reinforcements. Wire them from the `TransitionBaseSheet` buttons.

## Implementation Steps

1. **Create game_screen_transition_actions.dart** in `lib/presentation/screens/game/`:
   - Follow existing pattern from `game_screen_fight_actions.dart`

2. **handleAttackTransitionBase**:
   - Receive `transitionBase`, `x`, `y`, `level` from sheet
   - Navigate to `ArmySelectionScreen` (reuse) but with guardian preview
   - Or create a simpler selection flow → reuse existing ArmySelectionScreen with adapted parameters
   - On army selected: create `AttackTransitionBaseAction`, execute via `ActionExecutor`
   - On result: show `FightSummaryScreen` with capture banner if successful
   - After capture: update map cell state

3. **handleDescend**:
   - Open `DescentDialog` with `player.unitsOnLevel(level)`
   - On confirm: create `DescendAction`, execute
   - On success: switch `_currentLevel` to target level
   - Show brief confirmation message

4. **handleSendReinforcements**:
   - Open `ReinforcementDialog` with `player.unitsOnLevel(level)`
   - On confirm: create `SendReinforcementsAction`, execute
   - Show brief confirmation with expected arrival turn

5. **Wire from TransitionBaseSheet**:
   - `onAttack: () => handleAttackTransitionBase(...)`
   - `onDescend: () => handleDescend(...)`
   - `onReinforce: () => handleSendReinforcements(...)`

6. **Update map tap handler** in `game_screen_map_actions.dart`:
   - When tapping a cell with `CellContentType.transitionBase`:
     - Show `TransitionBaseSheet` instead of `CellInfoSheet`

## Dependencies
- **Internal**: Tasks 13-15 (actions), Task 23 (TransitionBaseSheet), Tasks 24-25 (dialogs), Task 26 (level switching)
- **External**: ActionExecutor, ArmySelectionScreen, FightSummaryScreen (existing)

## Test Plan
- Manual test: tap transition base → sheet appears → assault → fight → capture
- Manual test: capture → descend → Level 2 map shown
- Manual test: reinforce → units in transit → next turn → units arrive
- Run `flutter analyze`

## Notes
- This is the final integration task. After this, the full transition flow should be playable.
- Consider reusing `ArmySelectionScreen` for the assault flow with a `isBossight` flag to show guardian preview.
- Keep the helper file under 150 lines. Split into multiple files if needed.
