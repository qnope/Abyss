# Task 03 — Update ResourceBarItem Tests

## Summary

Update the existing `ResourceBarItem` widget tests to verify the new two-line layout. The rate text must appear below (not beside) the amount, and uniform height must be maintained when rate is absent.

## Implementation Steps

### File: `test/presentation/widgets/resource/resource_bar_item_test.dart`

1. **Update 'shows production rate when > 0' test:** Verify the rate text (`+8/t`) is still found. No structural change needed — the `find.text` still works regardless of layout direction.

2. **Add test: 'rate text appears below the amount':**
   - Pump a `ResourceBarItem` with production > 0.
   - Find the `Text` widget for amount (`'80'`) and the `Text` widget for rate (`'+8/t'`).
   - Assert that the rate text's vertical position (`tester.getTopLeft(find.text('+8/t')).dy`) is greater than the amount text's vertical position (`tester.getTopLeft(find.text('80')).dy`).

3. **Add test: 'uniform height when no rate':**
   - Pump a `ResourceBarItem` with production = 0 and consumption = 0.
   - Verify that the widget still contains a `Column` (or that the overall widget height is the same as when rate is present, by comparing `tester.getSize(find.byType(ResourceBarItem))` in both cases).

4. **Update 'hides production line when both are 0' test:**
   - The rate `/t` text should still not appear, but the item should still have the same height. Adjust the test: keep the `expect(find.textContaining('/t'), findsNothing)` assertion, and add a height check.

5. **Verify existing color tests still pass as-is** — color logic is unchanged, so `'uses alert color when consumption exceeds production'` and `'uses normal color when production covers consumption'` should pass without changes.

## Dependencies

- Task 01 (the layout must be changed first).

## Test Plan

- Run `flutter test test/presentation/widgets/resource/resource_bar_item_test.dart`.

## Notes

- Most existing tests should pass as-is because `find.text(...)` doesn't care about layout direction.
- The key new assertions are about vertical positioning of rate relative to amount.
