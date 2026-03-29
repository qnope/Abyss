# Task 01 — Setup flutter_svg and assets directory

## Summary

Add the `flutter_svg` dependency to the project and create the assets directory structure for resource icons. Declare the asset folder in `pubspec.yaml`.

## Implementation Steps

1. **Add `flutter_svg` dependency** in `pubspec.yaml`:
   - Add `flutter_svg: ^2.0.17` (or latest compatible) under `dependencies`.

2. **Create the assets directory**:
   - Create `assets/icons/resources/` directory.

3. **Declare assets in `pubspec.yaml`**:
   - Under `flutter:`, add:
     ```yaml
     assets:
       - assets/icons/resources/
     ```

4. **Run `flutter pub get`** to install the new dependency.

## Dependencies

- None (first task).

## Test Plan

- `flutter pub get` completes without errors.
- `flutter analyze` passes.

## Notes

- `flutter_svg` is the standard Flutter package for rendering SVG files.
- The assets directory must exist before Flutter can reference it, even if empty.
