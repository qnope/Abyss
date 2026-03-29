# Task 12: Write tests and validate

## Summary

Write unit and widget tests for all new components, fix any broken existing tests, and run `flutter analyze` + `flutter test` to validate.

## Implementation Steps

### Step 1: Create `test/domain/resource_test.dart`

```dart
void main() {
  group('Resource', () {
    test('creates with required fields');
    test('defaults: productionPerTurn=0, maxStorage=500');
  });
}
```

### Step 2: Update `test/domain/game_test.dart`

Add tests:
- `test('creates game with default 5 resources')` — verify `game.resources.length == 5`.
- `test('turn can be incremented')` — verify `game.turn++` works.

### Step 3: Update `test/presentation/widgets/resource_icon_test.dart`

- Update import to use `package:abyss/domain/resource_type.dart` instead of importing ResourceType from `resource_icon.dart`.

### Step 4: Create `test/presentation/widgets/resource_bar_test.dart`

Widget tests using `pumpWidget`:
- `test('renders all 5 resources')` — find 5 ResourceIcon widgets.
- `test('pearl is separated with divider')` — find vertical divider Container.
- `test('tapping resource opens bottom sheet')` — tap and verify bottom sheet appears.

### Step 5: Create `test/presentation/widgets/game_bottom_bar_test.dart`

Widget tests:
- `test('renders 4 tabs')` — find BottomNavigationBar with 4 items.
- `test('displays turn number')` — find text "Tour 1".
- `test('tab tap fires callback')` — tap tab and verify callback value.
- `test('next turn button fires callback')` — tap button and verify.
- `test('settings icon fires callback')` — tap icon and verify.

### Step 6: Create `test/presentation/screens/game_screen_test.dart`

Widget tests:
- `test('renders resource bar and bottom bar')`.
- `test('tab switching changes content')`.
- `test('next turn increments turn number')`.

Note: GameScreen tests may need a mock GameRepository. Use the existing `test/helpers/fake_game_repository.dart` if available, or create a simple fake.

### Step 7: Run validation

```bash
flutter analyze
flutter test
```

Fix any issues found.

## Dependencies

- All previous tasks (01–11) must be complete.

## Test Plan

This IS the test plan — all tests pass, no analysis errors.

## Notes

- Widget tests need `MaterialApp` wrapper for theme and navigation.
- SVG assets may need to be mocked in widget tests (use `SvgPicture.string` or mock asset bundle).
- The existing `test/helpers/fake_game_repository.dart` should be checked for compatibility with the updated Game model.
- Target: all tests pass, `flutter analyze` reports no issues.
