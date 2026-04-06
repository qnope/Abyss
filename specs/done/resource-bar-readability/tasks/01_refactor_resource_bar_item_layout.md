# Task 01 — Refactor ResourceBarItem to Two-Line Column Layout

## Summary

Change `ResourceBarItem` from a single-line `Row` (icon + amount + rate) to a two-line `Column`:
- **Line 1:** `Row` with `ResourceIcon` + `AnimatedResourceAmount`
- **Line 2:** Rate text (`+8/-2/t`) centered, or an empty `SizedBox` of the same height when no rate exists.

This ensures uniform item height regardless of whether the resource has production/consumption.

## Implementation Steps

### File: `lib/presentation/widgets/resource/resource_bar_item.dart`

1. Replace the outer `Row` inside the `GestureDetector` with a `Column(mainAxisSize: MainAxisSize.min)`.
2. First child of the `Column`: a `Row(mainAxisSize: MainAxisSize.min)` containing:
   - `ResourceIcon(type: resource.type, size: 20)`
   - `SizedBox(width: 4)`
   - `AnimatedResourceAmount(...)` (unchanged)
3. Second child of the `Column`: always rendered (not conditional).
   - When `production > 0 || consumption > 0`: a `Text` widget with `_rateText` and `_rateColor`, `fontSize: 11`.
   - Otherwise: a `SizedBox(height: <line-height>)` matching the text height to keep uniform spacing. Use a fixed height that matches `fontSize: 11` line height (~16px).
4. Remove the `if (production > 0 || consumption > 0)` conditional and the `SizedBox(width: 2)` spacer that was between amount and rate on the same row.
5. Keep `_rateText` and `_rateColor` methods unchanged.

## Dependencies

- None (self-contained widget change).

## Test Plan

- Tests are updated in Task 03.

## Notes

- The `Column` approach keeps `mainAxisSize: MainAxisSize.min` so the item doesn't expand vertically beyond its content.
- The empty `SizedBox` on line 2 ensures pearl (no production) has the same height as other resources.
