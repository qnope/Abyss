# Task 16: Widget Tests — UnitCard and ArmyListView

## Summary

Write widget tests for the unit card and army list view widgets.

## Implementation Steps

### 1. Create `test/presentation/widgets/unit_card_test.dart`

Setup: `mockSvgAssets()` / `clearSvgMocks()`

Helper: `createApp({required UnitType type, int count = 0, bool isUnlocked = true})`

- Unlocked card displays unit name (e.g., 'Eclaireur')
- Unlocked card shows count (e.g., '5 unites')
- Locked card shows 'Verrouille'
- Locked card shows lock icon (`Icons.lock`)
- Tapping card fires onTap callback
- Locked card has reduced opacity

### 2. Create `test/presentation/widgets/army_list_view_test.dart`

Setup: `mockSvgAssets()` / `clearSvgMocks()`

Helper: create default units map (all count 0)

- Shows 6 UnitCard widgets
- Barracks level 1: first 2 unlocked (scout, harpoonist), others locked
- Barracks level 5: all 6 unlocked
- Barracks level 0: all 6 locked
- Tap callback fires with correct UnitType

### 3. Create `test/presentation/widgets/unit_icon_test.dart`

Unit tests (not widget tests):
- Scout icon path is `assets/icons/units/scout.svg`
- DomeBreaker icon path is `assets/icons/units/dome_breaker.svg`
- Default size is 40
- Greyscale wraps in ColorFiltered

## Dependencies

- Tasks 08, 09, 10 (UnitIcon, UnitCard, ArmyListView)

## Test Plan

This IS the test task. Files listed above.

## Notes

- Use `mockSvgAssets()` from `test/helpers/test_svg_helper.dart` for all widget tests.
- Use `_useTallSurface()` if needed for list rendering.
- Follow existing test patterns from `building_card_test.dart` and `building_list_view_test.dart`.
