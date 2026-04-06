# Task 04 — Update ResourceBar Tests

## Summary

Update `ResourceBar` widget tests to account for the new two-line layout and updated divider height.

## Implementation Steps

### File: `test/presentation/widgets/resource/resource_bar_test.dart`

1. **Update 'pearl is separated with a divider' test:**
   - Change the divider height assertion from `24` to `36` (matching Task 02).
   - Update: `c.constraints?.maxHeight == 36`.

2. **Verify all existing tests still pass:** The `'renders all 5 resource items'`, `'shows resource amounts'`, `'default empty consumption does not break'`, and `'passes consumption to ResourceBarItem'` tests should work as-is.

## Dependencies

- Task 02 (divider height change).

## Test Plan

- Run `flutter test test/presentation/widgets/resource/resource_bar_test.dart`.

## Notes

- Minimal changes expected here. The main risk is the divider height assertion.
