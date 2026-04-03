# Task 06 — Create ActionExecutor

## Summary

Create the `ActionExecutor` class — the single entry point for validating and executing actions. It delegates to the action's `validate()` and `execute()` methods.

## Implementation Steps

1. Create `lib/domain/action_executor.dart`
2. Define class:
   ```dart
   import 'action.dart';
   import 'action_result.dart';
   import 'game.dart';

   class ActionExecutor {
     ActionResult execute(Action action, Game game) {
       final validation = action.validate(game);
       if (!validation.isSuccess) return validation;
       return action.execute(game);
     }
   }
   ```

## Dependencies

- Task 03 (`Action` abstract class)
- Task 02 (`ActionResult`)
- Existing: `Game` (`lib/domain/game.dart`)

## Test Plan

- See Task 07

## Notes

- The executor is intentionally thin for v1. Future transversal concerns (logging, action history, undo) can be added here.
- Keep file under 15 lines.
- The double validation (executor validates, then execute() validates internally) is intentional for defensive programming.
