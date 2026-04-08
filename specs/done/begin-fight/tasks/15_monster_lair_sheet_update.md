# Task 15 - MonsterLairSheet update

## Summary

Replace the current 'Combat non disponible' message in
`MonsterLairSheet` with a 'Préparer le combat' button that triggers
a callback (which the parent will use to push the army selection
screen) and an 'Annuler' button. Also surface the new lair info:
monster level, unit count, per-unit stats. When the cell is already
collected, show 'Vous êtes déjà venu par ici' (handled by the
existing collected branch in `game_screen_map_actions.dart`, so the
sheet only deals with the active state).

## Implementation steps

1. Update `lib/presentation/widgets/map/monster_lair_sheet.dart`:
   - Change the public `showMonsterLairSheet` signature to take:
     - `required MonsterLair lair`
     - `required VoidCallback onPrepareFight`
     (drop the standalone `difficulty` parameter -- pull it from `lair`).
   - In the sheet body, render:
     - Difficulty SVG (existing).
     - Title 'Monstre ($x, $y)'.
     - Info rows: 'Difficulté' (using `lair.difficulty.label`),
       'Niveau' (`lair.level`), 'Unités' (`lair.unitCount`),
       'PV / ATK / DEF' from `MonsterUnitStats.forLevel(lair.level)`.
   - Replace the warning message with a centred row containing:
     - `TextButton` 'Annuler' calling `Navigator.of(context).pop()`.
     - `ElevatedButton` 'Préparer le combat' that calls
       `Navigator.of(context).pop()` then `onPrepareFight()`.
   - Use `AbyssTheme` colours (`AbyssColors.biolumCyan` for the
     primary button) -- no hard-coded colours.

2. Keep the file under 150 lines. Extract the info rows to a private
   `_LairInfoSection` widget if needed.

## Dependencies

- **Internal**: `MonsterLair` (Task 01), `MonsterUnitStats` (Task 03),
  `AbyssColors`, `AbyssTheme`.
- **External**: `flutter_svg`.

## Test plan

- Update `test/presentation/widgets/map/monster_lair_sheet_test.dart`
  (create if missing):
  - Renders difficulty label, level, unit count, and stats.
  - 'Préparer le combat' button is present and tapping it calls the
    `onPrepareFight` callback exactly once.
  - 'Annuler' pops the sheet without calling `onPrepareFight`.
  - Mock SVG assets via the existing `mockSvgAssets` helper.

## Notes

- File target: < 150 lines.
- The sheet is now responsible only for showing info + dispatching
  to the army selection flow. Navigation lives in the parent.
- Use the project theme exclusively.
