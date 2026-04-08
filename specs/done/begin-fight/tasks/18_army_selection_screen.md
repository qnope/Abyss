# Task 18 - ArmySelectionScreen

## Summary

Full-page screen reached from `MonsterLairSheet`. The player picks
how many of each unit type to send against the lair, then taps
'Lancer le combat' to execute `FightMonsterAction` and navigate to
the fight summary screen.

## Implementation steps

1. Create `lib/presentation/screens/game/fight/army_selection_screen.dart`:
   - `StatefulWidget` `ArmySelectionScreen`.
   - Constructor:
     - `required Game game`
     - `required GameRepository repository`
     - `required int targetX`
     - `required int targetY`
     - `required MonsterLair lair`
     - `required VoidCallback onChanged` (called after the action so
       the parent map view rebuilds).
   - State holds `Map<UnitType, int> selected = {}` initialized with
     0 for every unit type currently in `player.units`.
   - Build:
     - `AppBar` titled 'Préparer le combat'.
     - Body in a `ListView`:
       - `MonsterPreview(lair: widget.lair)` at the top.
       - For each `UnitType` in `player.units` with `count > 0`:
         a `UnitQuantityRow(type: type, stock: count, value: selected[type] ?? 0, onChanged: ...)`.
       - Padding + bottom 'Lancer le combat' `ElevatedButton`,
         disabled if `selected.values.fold(0, +) == 0`.
       - 'Annuler' `TextButton` next to it that pops the screen.
     - On launch:
       1. Build the action via
          `FightMonsterAction(targetX, targetY, selectedUnits: nonZeroSelection)`.
       2. `result = ActionExecutor().execute(action, widget.game, widget.game.humanPlayer)`.
       3. `await widget.repository.save(widget.game)`.
       4. `widget.onChanged()`.
       5. `Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => FightSummaryScreen(result: result as FightMonsterResult, lair: widget.lair, targetX, targetY)))`.

2. Keep the file under 150 lines. Extract the launch handler and
   the body builder into private helpers if needed
   (`_buildBody`, `_onLaunchPressed`).

## Dependencies

- **Internal**: `Game`, `GameRepository`, `MonsterLair`, `UnitType`,
  `FightMonsterAction`, `FightMonsterResult`, `ActionExecutor`,
  `MonsterPreview` (Task 17), `UnitQuantityRow` (Task 16),
  `FightSummaryScreen` (Task 20), `AbyssTheme`.
- **External**: Flutter Material.

## Test plan

- New `test/presentation/screens/game/fight/army_selection_screen_test.dart`:
  - Lists every unit type the player has with `count > 0`.
  - Hides unit types with `count == 0`.
  - 'Lancer le combat' button is disabled when no units are selected.
  - Tapping `+` on a row enables the launch button.
  - Tapping the launch button executes `FightMonsterAction` (asserted
    via `FakeGameRepository`'s `saveCallCount` increment) and
    navigates to `FightSummaryScreen`.
  - Tapping 'Annuler' pops without calling save.
  - Mock SVG assets.

## Notes

- File target: < 150 lines.
- No `initialize()`.
- The screen owns the temporary selection state only; persistence
  happens through the action.
