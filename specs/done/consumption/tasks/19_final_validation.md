# Task 19: Final Validation

## Summary

Run `flutter analyze` and `flutter test` to ensure everything passes. Fix any issues found.

## Implementation Steps

### 1. Run `flutter analyze`
- Fix any lint errors or warnings
- Ensure no unused imports

### 2. Run `flutter test`
- All tests must pass
- Fix any failing tests

### 3. Verify file line counts
- All new/modified files must be under 150 lines
- Check: `consumption_calculator.dart`, `building_deactivator.dart`, `unit_loss_calculator.dart`, `turn_resolver.dart`, `turn_result.dart`, `resource_bar.dart`, `resource_bar_item.dart`, `turn_confirmation_dialog.dart`, `turn_summary_dialog.dart`, `game_screen.dart`
- If any file exceeds 150 lines, extract code into helper files

### 4. Verify all spec requirements
- US-1: Buildings consume energy ✓
- US-2: Units consume algae ✓
- US-3: Building deactivation with priority ✓
- US-4: Proportional unit losses ✓
- US-5: ResourceBar shows +X / -Y ✓
- US-6: Warnings before/after turn ✓

## Dependencies

- All tasks (1-18)

## Test Plan

- Run: `flutter analyze`
- Run: `flutter test`

## Notes

- This is the final validation step before the feature is complete
