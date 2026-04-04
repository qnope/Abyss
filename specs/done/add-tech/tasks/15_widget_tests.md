# Task 15 — Widget Tests

## Summary

Write widget tests for the tech tree UI: node widget, tree view, detail sheets, and the wired Tech tab.

## Implementation Steps

### 1. Create `test/presentation/widgets/tech_node_widget_test.dart`

- Use `mockSvgAssets()` from `test/helpers/test_svg_helper.dart`.
- Test researched state: full opacity, border solid.
- Test locked state: reduced opacity.
- Test accessible state: intermediate opacity.
- Test level badge: displays level number when `level` is set.
- Test `onTap` callback fires.

### 2. Create `test/presentation/widgets/tech_tree_view_test.dart`

- Use `mockSvgAssets()`.
- Test lab level 0: root node greyscale, 3 branch headers shown but all locked.
- Test lab level 1, all branches locked: branch headers accessible but locked state.
- Test military unlocked, level 2: nodes 1-2 researched, node 3 accessible, nodes 4-5 locked.
- Test `onBranchTap` callback: tap a branch header → callback called with correct `TechBranch`.
- Test `onNodeTap` callback: tap a sub-node → callback called with correct branch + level.

### 3. Create `test/presentation/widgets/tech_branch_detail_sheet_test.dart`

- Test: branch locked, lab built, resources OK → button enabled, shows costs.
- Test: branch locked, lab not built → button disabled, shows lab requirement message.
- Test: branch locked, insufficient resources → costs shown in red/error color.
- Test: branch already unlocked → shows success message.

### 4. Create `test/presentation/widgets/tech_node_detail_sheet_test.dart`

- Test: next node, resources OK, lab OK → button enabled, costs shown, bonus displayed.
- Test: already researched → shows "complétée" message.
- Test: future node → shows prerequisite message, button disabled.
- Test: lab level too low → button disabled.
- Test: bonus text correct: e.g. level 3 military → "+60% attaque et défense".

### 5. Update `test/presentation/screens/game_screen_test.dart`

- Test: tab 3 shows `TechTreeView` (not `TabPlaceholder`).
- Test: other tabs still work (regression).

### 6. Create `test/presentation/extensions/tech_branch_extensions_test.dart`

- Test all 3 branches have non-empty `displayName`, `description`, `iconPath`.
- Test colors are not null.

## Files

| Action | Path |
|--------|------|
| Create | `test/presentation/widgets/tech_node_widget_test.dart` |
| Create | `test/presentation/widgets/tech_tree_view_test.dart` |
| Create | `test/presentation/widgets/tech_branch_detail_sheet_test.dart` |
| Create | `test/presentation/widgets/tech_node_detail_sheet_test.dart` |
| Create | `test/presentation/extensions/tech_branch_extensions_test.dart` |
| Edit | `test/presentation/screens/game_screen_test.dart` |

## Dependencies

- Tasks 08–13 (all presentation code must be written first).
- Task 14 (domain tests should pass first).

## Design Notes

- All widget tests use `mockSvgAssets()` / `clearSvgMocks()` from `test/helpers/test_svg_helper.dart` (existing pattern).
- Create game fixtures with `Game(...)` including `techBranches` parameter.
- Use `pumpWidget(MaterialApp(home: Scaffold(body: ...)))` pattern for isolated widget tests.
- For bottom sheet tests, use `showModalBottomSheet` via the top-level function and `tester.pumpAndSettle()`.

## Test Plan

- Run `flutter test test/presentation/` — all green.
