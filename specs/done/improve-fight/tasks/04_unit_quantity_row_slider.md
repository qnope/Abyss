# Task 04 — UnitQuantityRow: add slider control

## Summary

Implement US-01: extend the existing `UnitQuantityRow` widget to
include a horizontal `Slider` (range `0..stock`, integer step) on
the same row, synchronized with the existing `+ / -` buttons.

Behavior:
- Slider `min: 0`, `max: stock`, `divisions: stock` (so each tick is
  one unit), `value: value.toDouble()`.
- Dragging the slider calls `onChanged(int)` with the rounded value.
- The `+` and `-` buttons keep their current behavior.
- When `stock == 1`, the slider is **still rendered** but with
  `min: 0, max: 1, divisions: 1`. The user explicitly asked for this
  behavior (no special-case hide).
- The widget remains stateless (controlled component) — the parent
  owns the `value`.
- The widget must stay below 150 lines.

## Files

- `lib/presentation/widgets/fight/unit_quantity_row.dart` — add
  the `Slider` and re-arrange the layout.
- `test/presentation/widgets/fight/unit_quantity_row_test.dart` — add
  slider tests, keep the existing button tests passing.

## Implementation steps

1. Open `lib/presentation/widgets/fight/unit_quantity_row.dart`.
2. Replace the single `Row` body with a `Column` containing:
   - **Top row** (current 64-px `SizedBox`/`Row`): icon, name+stock,
     `-`, current value, `+`. Unchanged structure.
   - **Bottom row**: a `Slider` filling the available width. Wrap in a
     `Padding(symmetric horizontal: 12)` so it visually aligns with
     the icon column.
3. Slider configuration:
   ```dart
   Slider(
     min: 0,
     max: stock.toDouble(),
     divisions: stock,
     value: value.toDouble().clamp(0, stock.toDouble()),
     onChanged: (double v) => onChanged(v.round()),
   )
   ```
4. Bump the outer `SizedBox` height (or remove the fixed height)
   to fit both rows. Prefer removing the fixed height and using
   `IntrinsicHeight` / natural sizing so future styling doesn't
   clip the slider.
5. Verify the file is still under 150 lines.

## Test plan

In `test/presentation/widgets/fight/unit_quantity_row_test.dart`,
extend the existing group with:

- **`renders Slider with correct max`** — pump with `stock: 5`,
  find a `Slider`, assert `slider.max == 5.0` and
  `slider.divisions == 5`.
- **`slider value reflects current value`** — pump with `value: 3,
  stock: 5`, assert `slider.value == 3.0`.
- **`dragging slider calls onChanged with rounded int`** — pump with
  `value: 0, stock: 5, onChanged: capture`, then call
  `tester.widget<Slider>(find.byType(Slider)).onChanged?.call(2.7)`,
  assert captured value is `3`.
- **`+ button updates remain in sync with slider`** — pump with
  `value: 2`, tap `+`, assert captured value is `3`. (Existing test;
  keep it.)
- **`stock == 1 still renders slider with max 1`** — pump with
  `stock: 1, value: 0`, find `Slider`, assert `slider.max == 1.0`
  and `slider.divisions == 1`.

Existing tests (`renders unit label and stock`, `+/- disabled
states`) must keep passing untouched.

## Dependencies

- Internal: none beyond the existing widget.
- External: `Slider` from `package:flutter/material.dart` (already
  imported transitively).
- Blocks: task 06 (the new screen layout will rely on this widget).

## Notes

- Do not introduce a `StatefulWidget` here; keep it controlled.
- Do not extract a separate "slider widget" — the slider is one
  Material widget call, an extra abstraction would violate
  CLAUDE.md's "no helpers for one-time operations" rule.
- The user explicitly requested the slider stay visible at
  `stock == 1` ("If stock == 1, slider on left is 0, slider on right
  is 1"), so the spec line "Si le stock disponible est `1`, le slider
  est masqué ou désactivé" is overridden by the user's later
  clarification.
