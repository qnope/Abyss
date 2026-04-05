# Task 12: Test ResourceBar Consumption Display

## Summary

Write widget tests for the updated `ResourceBarItem` and `ResourceBar` consumption display.

## Implementation Steps

### 1. Update `test/presentation/widgets/resource_bar_item_test.dart`

#### Group: `consumption display`
- `shows only production when consumption is 0` — production=50, consumption=0 → finds `+50/t`, no `-`
- `shows production and consumption` — production=50, consumption=12 → finds `+50/-12/t`
- `uses alert color when consumption exceeds production` — production=10, consumption=20 → verify text color is `AbyssColors.error`
- `uses normal color when production covers consumption` — production=50, consumption=10 → verify text color is resource color (not error)
- `hides production line when both are 0` — production=0, consumption=0 → no `/t` text

### 2. Update `test/presentation/widgets/resource_bar_test.dart`

#### New group: `consumption`
- `passes consumption to ResourceBarItem` — ResourceBar with consumption map → verify ResourceBarItem receives consumption value
- `existing tests still pass` — verify all previous tests work with default empty consumption

## Dependencies

- Task 11 (ResourceBar updated)

## Test Plan

- Run: `flutter test test/presentation/widgets/resource_bar_item_test.dart`
- Run: `flutter test test/presentation/widgets/resource_bar_test.dart`

## Notes

- Use `mockSvgAssets()` / `clearSvgMocks()` as in existing tests
- Wrap widgets in `MaterialApp` with `AbyssTheme.create()` for proper theme
