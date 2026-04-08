# Task 16 - UnitQuantityRow widget

## Summary

Reusable row widget that displays a unit type with its current stock,
its stats, and an inline quantity selector (`-` / `+` and a number).
Used by the army selection screen to let the player pick how many of
each unit type to send.

## Implementation steps

1. Create `lib/presentation/widgets/fight/unit_quantity_row.dart`:
   - Stateless widget `UnitQuantityRow`.
   - Constructor parameters:
     - `required UnitType type`
     - `required int stock`
     - `required int value`
     - `required ValueChanged<int> onChanged`
   - Layout (single row, ~64dp tall):
     - `UnitIcon` (existing widget) on the left.
     - Two-line text in the middle: type name + 'Stock: $stock'.
     - Group on the right: `IconButton` `-`, current `value`, `IconButton` `+`.
   - Constraints:
     - `-` button disabled when `value == 0`; calls
       `onChanged(value - 1)`.
     - `+` button disabled when `value == stock`; calls
       `onChanged(value + 1)`.
   - Use `AbyssColors` and `AbyssTheme` text styles.

## Dependencies

- **Internal**: `UnitType`, existing `UnitIcon` widget,
  `AbyssTheme` / `AbyssColors`.
- **External**: Flutter Material.

## Test plan

- New `test/presentation/widgets/fight/unit_quantity_row_test.dart`:
  - Renders the unit type label and 'Stock: 10'.
  - Tapping `+` calls `onChanged(value + 1)`.
  - Tapping `-` calls `onChanged(value - 1)`.
  - When `value == 0`, the `-` button is disabled and the callback
    is not invoked.
  - When `value == stock`, the `+` button is disabled and the
    callback is not invoked.
  - Mock SVG assets for the unit icon via the helper.

## Notes

- File target: < 120 lines.
- Pure stateless widget; the parent owns the value.
