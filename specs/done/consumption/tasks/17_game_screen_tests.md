# Task 17: Test GameScreen Consumption Wiring

## Summary

Update existing GameScreen tests to verify consumption data is passed correctly to ResourceBar and turn dialogs.

## Implementation Steps

### 1. Update `test/presentation/screens/game_screen_test.dart`

#### New group: `consumption display`
- `resource bar shows energy consumption` — Game with HQ lvl 1 (3 energy consumption). Verify ResourceBar displays consumption indicator.
- `resource bar shows algae consumption` — Game with scouts. Verify ResourceBar displays algae consumption.

#### New group: `turn with consumption`
- `turn confirmation shows deactivation warning` — Game with buildings but no solar panel, low energy stock. Tap next turn. Verify warning appears in confirmation dialog.
- `turn confirmation shows unit loss warning` — Game with units but no algae farm, low algae stock. Tap next turn. Verify unit loss warning in confirmation dialog.
- `turn summary shows consumption results` — Complete a turn with consumption. Verify summary shows consumption data.

## Dependencies

- Task 16 (GameScreen updated)

## Test Plan

- Run: `flutter test test/presentation/screens/game_screen_test.dart`

## Notes

- May need to update existing game_screen tests if they break due to consumption changes
- Use the existing test patterns (mock repository, pump widget, etc.)
