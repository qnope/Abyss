# Task 21 - Wire fight navigation in game_screen_map_actions

## Summary

Connect the new fight flow to the existing map tap routing. When the
player taps a non-collected monster lair, `MonsterLairSheet` now
exposes a 'Préparer le combat' button; this task plumbs the callback
that pushes `ArmySelectionScreen`. After the screen returns, the map
must rebuild via the existing `onChanged` chain.

## Implementation steps

1. Edit `lib/presentation/screens/game/game_screen_map_actions.dart`:
   - Update the `CellContentType.monsterLair` branch in
     `_showCellAction` to read `cell.lair!` (Task 01) and call the
     new `showMonsterLairSheet` signature:
     ```dart
     showMonsterLairSheet(
       context,
       targetX: x,
       targetY: y,
       lair: cell.lair!,
       onPrepareFight: () => _openArmySelection(
         context, game, repository, x, y, cell.lair!, onChanged,
       ),
     );
     ```
   - Add a private helper:
     ```dart
     void _openArmySelection(
       BuildContext context,
       Game game,
       GameRepository repository,
       int x, int y,
       MonsterLair lair,
       VoidCallback onChanged,
     ) {
       Navigator.of(context).push(MaterialPageRoute(
         builder: (_) => ArmySelectionScreen(
           game: game,
           repository: repository,
           targetX: x,
           targetY: y,
           lair: lair,
           onChanged: onChanged,
         ),
       ));
     }
     ```
   - Make sure `buildMapTab` already passes `repository` (it does).
     Thread it through `_showCellAction` if not already.

2. Verify the helper file stays under 150 lines. If it crosses,
   move `_openArmySelection` and any related fight wiring into a
   new file `lib/presentation/screens/game/game_screen_fight_actions.dart`
   and import it from `game_screen_map_actions.dart`.

## Dependencies

- **Internal**: Updated `MonsterLairSheet` (Task 15),
  `ArmySelectionScreen` (Task 18), `MonsterLair` (Task 01).
- **External**: Flutter Material.

## Test plan

- Update `test/presentation/screens/game_screen_test.dart` (or
  add a new file) to:
  - Render `GameScreen` with a generated map containing a monster
    lair, simulate a tap on that cell, expect `MonsterLairSheet` to
    appear.
  - Tap 'Préparer le combat'; expect `ArmySelectionScreen` to be
    on the navigator stack.
- Add a focused widget test in
  `test/presentation/screens/game/fight/army_selection_navigation_test.dart`
  exercising the helper directly with a fake repository.

## Notes

- The current `_showCellAction` does not currently take `repository`;
  thread it through (it's already in scope from `buildMapTab`'s
  closure -- pass it via the closure if needed).
- File target: < 150 lines for `game_screen_map_actions.dart`.
