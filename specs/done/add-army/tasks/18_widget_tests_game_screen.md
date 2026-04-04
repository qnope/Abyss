# Task 18: Widget Tests — GameScreen Army Tab Integration

## Summary

Add integration tests to the existing GameScreen test file to verify the Army tab works end-to-end.

## Implementation Steps

### 1. Update `test/presentation/screens/game_screen_test.dart`

Add a new test group `'Army tab'`:

**Setup**: create a game with barracks level 1 and sufficient resources for recruitment.

- **Army tab shows unit cards**: navigate to Army tab (tap 'Armee'), verify 6 UnitCard widgets appear
- **Locked units shown**: with barracks 1, guardian card shows 'Verrouille'
- **Tapping locked unit shows unlock message**: tap guardian card, verify "Caserne niveau 3 requise pour debloquer"
- **Tapping unlocked unit shows detail**: tap scout card, verify stats (PV, ATQ, DEF) appear
- **Recruit units**: tap scout → move slider → tap 'Recruter' → verify resources deducted and unit count updated
- **Recruitment blocked after recruiting same type**: recruit scout, tap scout again → verify "Recrutement deja effectue ce tour"
- **Different type still available**: recruit scout, then tap harpoonist → slider is available (not blocked)

## Dependencies

- Task 13 (Army tab wired in GameScreen)
- All prior tasks (domain + presentation)

## Test Plan

This IS the test task. File listed above.

## Notes

- Add to existing `game_screen_test.dart` — don't create a new file.
- Use `FakeGameRepository` from test helpers.
- Need a game with barracks level >= 1 and enough resources. Use `_createGame()` helper or modify existing one.
- Tab navigation: tap `find.text('Armee')` to switch to Army tab.
