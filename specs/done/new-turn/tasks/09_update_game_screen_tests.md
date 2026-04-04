# Task 09 — Update GameScreen tests

## Summary

Update existing GameScreen tests for the new turn flow and add integration-level widget tests covering the full confirm → resolve → summary cycle.

## Implementation Steps

1. Open `test/presentation/screens/game_screen_test.dart`
2. Update the existing `'next turn increments turn number'` test:
   - After tapping "Tour suivant", the confirmation dialog appears
   - Tap "Confirmer" to proceed
   - Then the summary dialog appears — tap "OK" to dismiss
   - Verify turn is now 2
3. Add new test cases:

### Confirmation dialog
- **Tapping "Tour suivant" shows confirmation dialog**: finds `'Passer au tour suivant ?'`
- **Cancel keeps same turn**: tap "Tour suivant" → tap "Annuler" → turn still 1

### Resource update
- **Resources increase after turn**: create game with AlgaeFarm level 1, verify algae increases by 5 after confirming turn
- **Resource capped at maxStorage**: create game with algae at 498/500 and AlgaeFarm level 1 → after turn, algae is 500

### Auto-save
- **Game is saved after turn**: use `FakeGameRepository` and verify `save()` was called

### Summary dialog
- **Summary dialog appears after confirming**: after confirming, finds `'Resume du tour'`

## Dependencies

- Task 08 (refactored `GameScreen`)
- Existing: `FakeGameRepository`, `test_svg_helper.dart`, `AbyssTheme`

## Test Plan

- **File**: `test/presentation/screens/game_screen_test.dart`
- Run: `flutter test test/presentation/screens/game_screen_test.dart`

## Notes

- The `FakeGameRepository` may need a `saveCallCount` or `lastSavedGame` field to verify auto-save. Check `test/helpers/fake_game_repository.dart` and add if needed.
- Some tests need custom `Game` setups with specific building levels and resource amounts.
- Use `await tester.pumpAndSettle()` after dialog interactions.
