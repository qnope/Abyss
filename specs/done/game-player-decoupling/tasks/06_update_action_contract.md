# Task 06 — Update `Action` contract and `ActionExecutor` to carry a `Player`

## Summary

Change the `Action` abstract class so that `validate` and `execute` take both a `Game` and a `Player`. Update `ActionExecutor` to forward the player. No action implementation is changed in this task — only the contract and the executor.

## Implementation Steps

1. **Edit `lib/domain/action/action.dart`**
   ```dart
   import '../game/game.dart';
   import '../game/player.dart';
   import 'action_result.dart';
   import 'action_type.dart';

   abstract class Action {
     ActionType get type;
     String get description;
     ActionResult validate(Game game, Player player);
     ActionResult execute(Game game, Player player);
   }
   ```
2. **Edit `lib/domain/action/action_executor.dart`**
   ```dart
   class ActionExecutor {
     ActionResult execute(Action action, Game game, Player player) {
       final validation = action.validate(game, player);
       if (!validation.isSuccess) return validation;
       return action.execute(game, player);
     }
   }
   ```
3. **Leave concrete actions broken** — tasks 07–11 re-implement each one against the new signature. The project will not compile between this task and task 11, but each action task is small and the pain window is short.

## Dependencies

- Task 02 (`Player` exists as a parameter type).
- Task 05 (new `Game` shape — executor doesn't touch fields directly, but importing the updated `Game` is cleaner once its state is gone).

## Test Plan

No standalone tests in this task; `ActionExecutor` is exercised by every action test in task 20.

## Notes

- After this task, all files under `lib/domain/action/*.dart` that extend `Action` will fail to compile because their `validate`/`execute` overrides still have the old signature. That's expected — tasks 07–11 fix them in order.
- UI call sites that invoke `ActionExecutor().execute(action, game)` (notably `game_screen_map_actions.dart`) will also break; they are migrated in task 17.
