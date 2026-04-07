# Task 04 — Create ResourceGainDialog widget

## Summary

Create a reusable modal dialog that displays a list of resources gained (icon + `+amount`) with a title and an OK button. Handles the empty case (all deltas are zero) by showing an "empty" message instead of the list.

The dialog will be triggered after a `CollectTreasureAction` succeeds, but its API takes a generic `Map<ResourceType, int>` so it stays reusable for any future "you gained" feedback.

## Implementation Steps

1. **Create `lib/presentation/widgets/resource/resource_gain_dialog.dart`**

   ```dart
   import 'package:flutter/material.dart';
   import '../../../domain/resource/resource_type.dart';
   import '../../extensions/resource_type_extensions.dart';
   import '../../theme/abyss_colors.dart';
   import 'resource_icon.dart';

   Future<void> showResourceGainDialog(
     BuildContext context, {
     required String title,
     required Map<ResourceType, int> deltas,
     String emptyMessage = 'Rien à récupérer ici...',
   }) {
     return showDialog<void>(
       context: context,
       builder: (_) => _ResourceGainDialog(
         title: title,
         deltas: deltas,
         emptyMessage: emptyMessage,
       ),
     );
   }
   ```

2. **Implement the private `_ResourceGainDialog` widget**
   - Filter deltas: only entries where `value > 0`.
   - If the filtered list is empty → show `Text(emptyMessage)` as the body.
   - Otherwise → show a `Column(mainAxisSize: MainAxisSize.min)` with one row per resource:
     - `ResourceIcon(type: type)` (size 24)
     - `SizedBox(width: 8)`
     - `Text(type.displayName)` from `ResourceTypeInfo` extension
     - `Spacer()`
     - `Text('+$amount', style: TextStyle(color: type.color))` from `ResourceTypeColor` extension
   - Wrap rows in `Padding(symmetric vertical: 4)` for breathing room — match `turn_summary_dialog._buildResourceLine` style.
   - `AlertDialog`:
     - `title`: `Text(title, style: ... color: AbyssColors.biolumCyan)` — match the headline color used in `treasure_sheet.dart`.
     - `content`: the column or empty text.
     - `actions`: `[ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]`

3. **Iteration order**
   - Iterate by `ResourceType.values` (not `deltas.keys`) so the display order is deterministic and matches the canonical resource order across the UI.

## Dependencies

- None on other collect-sheet tasks. Uses existing `ResourceIcon`, `ResourceTypeColor`, `ResourceTypeInfo`, and `AbyssColors`.

## Test Plan

- **File:** `test/presentation/widgets/resource/resource_gain_dialog_test.dart`
- Test cases:
  - **Renders one line per non-zero resource**: pump a host widget that calls `showResourceGainDialog` with `{algae: 75, coral: 0, ore: 12}`. Expect to find `Text('+75')` and `Text('+12')`, but NOT `Text('+0')`.
  - **Hides resources with zero delta**: same as above; explicitly assert `findsNothing` for any text containing the zero entry.
  - **Empty deltas show empty message**: pass `{algae: 0, coral: 0}` (or `{}`) and a custom `emptyMessage`. Expect to find that message and NOT find any `+` text.
  - **OK button closes the dialog**: tap the OK button, pump, expect the dialog to be gone (`find.byType(AlertDialog)` returns nothing).
  - **Title is rendered**: pass a `title: 'Trésor collecté !'`, expect to find that text.
  - **Order is canonical**: with deltas for `{pearl: 1, algae: 1}`, expect algae's row to appear before pearl's row in the widget tree.

## Notes

- File target: ~80 lines, well under the 150-line cap.
- Reuses `ResourceIcon` (24px default) and the `displayName` / `color` extensions — no duplication.
- The dialog must NOT depend on `CollectTreasureResult` directly so it stays reusable. The caller is responsible for extracting `result.deltas` and passing it in.
