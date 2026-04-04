# Task 06 — Turn summary dialog

## Summary

Create the post-turn summary dialog that shows the player what happened during the turn: resources gained and whether any were capped.

## Implementation Steps

1. Create `lib/presentation/widgets/turn_summary_dialog.dart`
2. Create a top-level function:
   ```dart
   Future<void> showTurnSummaryDialog(
     BuildContext context, {
     required TurnResult result,
   }) {
     return showDialog<void>(
       context: context,
       builder: (ctx) => _TurnSummaryDialog(result: result),
     );
   }
   ```
3. Implement `_TurnSummaryDialog` as a private `StatelessWidget`:
   - Title: `'Resume du tour'`
   - Content: list of `TurnResourceChange` entries, each showing:
     - `ResourceIcon` + display name + `'+$produced'`
     - If `wasCapped`: append `' (max atteint)'` in `AbyssColors.warning` color
   - If no changes: show `'Aucun changement ce tour.'`
   - Actions: single `ElevatedButton('OK')` → `Navigator.pop(ctx)`
4. Use `ResourceTypeInfo.displayName` and `ResourceTypeColor.color` for styling.

## Dependencies

- Task 01 (`TurnResult`, `TurnResourceChange`)
- Existing: `ResourceType`, `ResourceIcon`, `resource_type_extensions.dart`, `AbyssColors`

## Test Plan

- No tests in this task — see task 07.

## Notes

- Use `AlertDialog` which inherits the Abyss dialog theme.
- Keep file under 60 lines.
- The "max atteint" indicator is per US-04 acceptance criteria.
