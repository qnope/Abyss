# Task 02 — Update ResourceBar Divider Height

## Summary

The pearl divider in `ResourceBar` has a fixed height of `24`. With the new two-line layout, the items are taller. Update the divider height to match.

## Implementation Steps

### File: `lib/presentation/widgets/resource/resource_bar.dart`

1. Locate the `Container` used as a divider (line ~47):
   ```dart
   Container(
     width: 1,
     height: 24,
     ...
   )
   ```
2. Increase `height` from `24` to `36` to visually match the new two-line item height (~20px icon line + ~16px rate line).

## Dependencies

- Task 01 (the item height changes first, then divider adapts).

## Test Plan

- Tests are updated in Task 04.

## Notes

- The exact value (36) may need fine-tuning. It should visually span both lines of the resource item without exceeding the bar height.
