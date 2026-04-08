# Task 01 — Add `uuid` dependency

## Summary

Add the `uuid` package to the project so that each `Player` can be assigned a unique identifier. No Dart code is written yet — this only updates `pubspec.yaml` and fetches the package.

## Implementation Steps

1. **Edit `pubspec.yaml`**
   - Under `dependencies:`, add `uuid: ^4.4.0` (or the latest stable v4.x line).
   - Keep the file alphabetically ordered if it already is; otherwise place it after existing entries.
2. **Fetch the package**
   - Run `flutter pub get`.
3. **Verify**
   - Confirm `pubspec.lock` now references `uuid`.
   - Confirm no other entries were accidentally changed.

## Dependencies

- None (foundation task).

## Test Plan

- No new tests. Validation is "the project still resolves".
- `flutter pub get` completes without errors.

## Notes

- We use `Uuid().v4()` (random UUID) in task 02 when constructing `Player`.
- If the package is already listed, skip the edit and just verify `pubspec.lock`.
