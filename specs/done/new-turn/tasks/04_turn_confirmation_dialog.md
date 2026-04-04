# Task 04 — Turn confirmation dialog

## Summary

Create the confirmation dialog that appears when the player presses "Tour suivant". It shows a production preview per resource and offers "Annuler" / "Confirmer" buttons.

## Implementation Steps

1. Create `lib/presentation/widgets/turn_confirmation_dialog.dart`
2. Create a top-level function:
   ```dart
   Future<bool> showTurnConfirmationDialog(
     BuildContext context, {
     required Map<ResourceType, int> production,
   }) async {
     final result = await showDialog<bool>(
       context: context,
       builder: (ctx) => _TurnConfirmationDialog(production: production),
     );
     return result ?? false;
   }
   ```
3. Implement `_TurnConfirmationDialog` as a private `StatelessWidget`:
   - Title: `'Passer au tour suivant ?'`
   - Content: list of resources with production > 0, each showing `ResourceIcon` + display name + `'+$amount'`
   - If production is empty, show a message like `'Aucune production ce tour.'`
   - Actions: `TextButton('Annuler')` → `Navigator.pop(ctx, false)`, `ElevatedButton('Confirmer')` → `Navigator.pop(ctx, true)`
4. Use `ResourceTypeInfo.displayName` from `resource_type_extensions.dart` for resource names.
5. Use `ResourceIcon` widget for resource icons.
6. Use `ResourceTypeColor.color` for the production amount text color.

## Dependencies

- Existing: `ResourceType`, `ResourceIcon`, `resource_type_extensions.dart`

## Test Plan

- No tests in this task — see task 05.

## Notes

- Use `AlertDialog` which inherits the Abyss dialog theme automatically.
- Keep file under 60 lines.
- Only show resources with production > 0 (per US-01 acceptance criteria).
