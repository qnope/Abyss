# Task 13 — Settings Dialog Integration

## Summary

Add a "Voir l'historique" button to `settings_dialog.dart` that opens the history sheet. The existing "Sauvegarder et quitter" button keeps its current behavior. Because the dialog currently returns a `bool`, its API must evolve to distinguish "open history" from "save and quit" from "cancel".

## Implementation Steps

1. Edit `lib/presentation/widgets/common/settings_dialog.dart`:
   - Introduce `enum SettingsDialogResult { cancel, saveAndQuit, openHistory }`.
   - Change the function signature to `Future<SettingsDialogResult> showSettingsDialog(BuildContext context)` and return `SettingsDialogResult.cancel` if the dialog is dismissed.
   - Add a third action button `TextButton` labeled `Voir l'historique` that pops with `SettingsDialogResult.openHistory`.
   - Keep "Sauvegarder et quitter" → `SettingsDialogResult.saveAndQuit`.
   - Keep "Annuler" → `SettingsDialogResult.cancel`.
2. Update `lib/presentation/screens/game/game_screen.dart` `_showSettings`:
   ```dart
   Future<void> _showSettings() async {
     final result = await showSettingsDialog(context);
     if (!mounted) return;
     switch (result) {
       case SettingsDialogResult.cancel:
         return;
       case SettingsDialogResult.openHistory:
         await showHistorySheet(context, player: _human);
         return;
       case SettingsDialogResult.saveAndQuit:
         await widget.repository.save(widget.game);
         if (!mounted) return;
         Navigator.of(context).pushAndRemoveUntil(
           MaterialPageRoute<void>(
             builder: (_) => MainMenuScreen(repository: widget.repository),
           ),
           (_) => false,
         );
         return;
     }
   }
   ```
3. Verify every other call site of `showSettingsDialog` across the repo:
   - There should be a single usage (game_screen). If more exist, update each to the new enum-returning API.

## Dependencies

- Blocks: task 14 (integration tests).
- Blocked by: task 12 (history sheet).

## Test Plan

- `test/presentation/widgets/common/settings_dialog_test.dart`:
  - Tap "Annuler" → returns `cancel`.
  - Tap "Sauvegarder et quitter" → returns `saveAndQuit`.
  - Tap "Voir l'historique" → returns `openHistory`.
- `test/presentation/screens/game/game_screen_settings_test.dart`:
  - Mock the settings dialog to return `openHistory` → the history sheet appears without navigating away from the game.
  - Mock to return `saveAndQuit` → the repository `save` is called and navigation goes back to main menu.

## Notes

- Update `lib/presentation/widgets/common/settings_dialog.dart` to stay under 150 lines — it's currently 23 lines, plenty of room.
- French labels only.
- The history sheet must reuse the existing game state — do not clone the player.
