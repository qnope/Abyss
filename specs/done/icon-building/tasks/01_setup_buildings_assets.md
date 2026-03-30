# Task 01 - Setup buildings assets directory

## Summary
Create the `assets/icons/buildings/` directory and register it in `pubspec.yaml` so Flutter can find the building icon assets.

## Implementation Steps

1. Create directory `assets/icons/buildings/`
2. Edit `pubspec.yaml` to add the new asset path:
   - Find the existing `assets/icons/resources/` entry under `flutter > assets`
   - Add `- assets/icons/buildings/` below it

## Dependencies
- None (first task)

## Test Plan
- Run `flutter analyze` to verify pubspec.yaml is valid
- No unit tests needed for this task

## Notes
- This must be done before any SVG files are created, as Flutter needs the asset directory registered
