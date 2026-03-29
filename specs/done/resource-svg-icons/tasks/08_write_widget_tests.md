# Task 08 — Write widget tests for ResourceIcon

## Summary

Write widget tests that verify all 5 resource SVG icons load correctly through the `ResourceIcon` widget, and that the widget behaves as expected.

## Implementation Steps

1. **Create test file** `test/presentation/widgets/resource_icon_test.dart`.

2. **Test cases**:

   a. **Each ResourceType renders without error**:
      - For each value in `ResourceType.values`, pump a `ResourceIcon(type: type)` and verify no exceptions.
      - Use `find.byType(SvgPicture)` to confirm the SVG widget is in the tree.

   b. **Default size is 24px**:
      - Pump `ResourceIcon(type: ResourceType.algae)` and verify the `SvgPicture` has `width: 24` and `height: 24`.

   c. **Custom size is applied**:
      - Pump `ResourceIcon(type: ResourceType.coral, size: 48)` and verify dimensions.

   d. **Asset path correctness**:
      - Verify that the asset path for each type matches `assets/icons/resources/<name>.svg`.

3. **Test setup**:
   - SVG assets need to be available in tests. Use `DefaultAssetBundle` mock or ensure test runner has access to assets via `flutter test`.

## Dependencies

- Task 07 (ResourceIcon widget must exist).
- Tasks 02-06 (SVG assets must be present for loading tests).

## Test Plan

- Run `flutter test test/presentation/widgets/resource_icon_test.dart`.
- All tests pass.
- Run `flutter analyze` — no issues.

## Notes

- `flutter_svg` in tests may require asset bundle configuration. If loading fails in tests, we can test the widget structure without actual asset loading (verify `SvgPicture.asset` is called with the right path).
- Keep tests focused: we're testing the widget mapping, not the SVG rendering engine.
