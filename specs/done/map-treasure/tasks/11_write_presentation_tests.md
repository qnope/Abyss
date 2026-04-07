# Task 11 — Write presentation tests

## Summary

Write widget tests verifying the correct bottom sheet is displayed for each cell type/state combination, and that collection actions work end-to-end in the UI.

## Implementation Steps

1. **Create `test/presentation/widgets/map/cell_info_sheet_test.dart`**
   - Test title, message, and optional icon rendering (as described in task 06)

2. **Create `test/presentation/widgets/map/treasure_sheet_test.dart`**
   - Test resourceBonus display (type + amount)
   - Test ruins display (random reward description)
   - Test "Collecter le trésor" button triggers callback

3. **Create `test/presentation/widgets/map/monster_lair_sheet_test.dart`**
   - Test difficulty label for each level
   - Test "Combat non disponible" message

4. **Update `test/presentation/widgets/map/map_cell_widget_test.dart`**
   - Add collected cell opacity tests (as described in task 09)

## Dependencies

- Task 06 (CellInfoSheet)
- Task 07 (TreasureSheet)
- Task 08 (MonsterLairSheet)
- Task 09 (MapCellWidget greyed icons)

## Test Plan

- Run `flutter test test/presentation/widgets/map/`
- All new and existing tests pass

## Notes

- Use `MaterialApp(home: Scaffold(body: ...))` wrapper pattern from existing tests.
- For SVG assets in tests, use the existing SVG mock helpers if available.
- Bottom sheet tests may need `showModalBottomSheet` — use `tester.tap` + `tester.pumpAndSettle`.
