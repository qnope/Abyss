# Task 03 — Create abstract Action class

## Summary

Create the abstract `Action` class that all game actions extend. It defines the contract: every action has a type, a description, and can be validated/executed against a `Game`.

## Implementation Steps

1. Create `lib/domain/action.dart`
2. Define abstract class:
   ```dart
   import 'action_result.dart';
   import 'action_type.dart';
   import 'game.dart';

   abstract class Action {
     ActionType get type;
     String get description;
     ActionResult validate(Game game);
     ActionResult execute(Game game);
   }
   ```

## Dependencies

- Task 01 (`ActionType`)
- Task 02 (`ActionResult`)
- Existing: `Game` (`lib/domain/game.dart`)

## Test Plan

- No dedicated test file — this is an abstract class with no logic.
- Concrete implementations are tested in tasks 04–05.

## Notes

- The name `Action` may shadow `dart:core` in some contexts, but Dart allows it since it's in a custom package namespace. If there's a conflict with Flutter's `Action` widget class, use an import prefix in affected files.
- Keep file under 15 lines.
