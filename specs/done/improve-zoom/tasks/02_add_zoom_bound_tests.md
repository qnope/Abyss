# Task 02 — Add zoom-bound tests

## Summary

Add tests that verify the `InteractiveViewer` is configured with the correct `minScale` and `maxScale` values, ensuring the max zoom corresponds to 1 visible cell.

## Implementation Steps

1. Open `test/presentation/widgets/map/game_map_view_test.dart`
2. Add a test that verifies `maxScale` equals `screenWidth / (1.0 * cellSize)`:
   - Pump a `GameMapView` inside a `MaterialApp` with a known screen size (default test size is 800×600).
   - Find the `InteractiveViewer` widget.
   - Assert `maxScale` == `800.0 / (1.0 * 48.0)` ≈ `16.667`.
3. Add a test that verifies `minScale` equals `screenWidth / gridSize`:
   - Same setup.
   - Assert `minScale` == `800.0 / (20 * 48.0)` ≈ `0.833`.
4. Add a test that verifies the default visible cells constant produces the correct initial scale:
   - After `pumpAndSettle`, read the `TransformationController` value from state.
   - Assert the scale component of the matrix equals `800.0 / (8.0 * 48.0)` ≈ `2.083`.

## Files Modified

| File | Change |
|------|--------|
| `test/presentation/widgets/map/game_map_view_test.dart` | Add 3 new tests in existing group |

## Dependencies

- Task 01 must be completed first (tests validate the new constant value).

## Test Plan

- Run `flutter test test/presentation/widgets/map/game_map_view_test.dart`
- All 6 tests should pass (3 existing + 3 new).

## Notes

- Flutter test framework default screen size is 800×600. Use `tester.view.physicalSize` / `tester.view.devicePixelRatio` if needed, or set explicitly via `tester.binding.setSurfaceSize`.
- The `InteractiveViewer` widget properties can be accessed via `tester.widget<InteractiveViewer>(find.byType(InteractiveViewer))`.
