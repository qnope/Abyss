# Task 20 — Update action tests for per-player signatures

## Summary

Every existing action test builds a `Game`, calls `action.execute(game)`, and asserts on `game.resources` / `game.buildings` / etc. Update every test to build a `Player`, call `action.execute(game, player)`, and assert on `player.*`. Also add the "collectedBy is stamped with the calling player's id" test for `CollectTreasureAction`.

## Implementation Steps

1. **Identify the test files**
   - `test/domain/action/collect_treasure_action_validate_test.dart`
   - `test/domain/action/collect_treasure_action_execute_test.dart`
   - `test/domain/action/explore_action_test.dart` (or however it's named)
   - `test/domain/action/upgrade_building_action_test.dart`
   - `test/domain/action/recruit_unit_action_test.dart`
   - `test/domain/action/research_tech_action_test.dart`
   - `test/domain/action/unlock_branch_action_test.dart`
   - `test/domain/action/collect_treasure_action_helper.dart` (shared helper).
2. **For each file**
   - Import `../../../lib/domain/game/player.dart`.
   - Build the test `Player` explicitly — typically with:
     ```dart
     Player testPlayer({String id = 'test-uuid'}) =>
         Player(id: id, name: 'Test', baseX: 10, baseY: 10);
     ```
   - Replace every `ActionExecutor().execute(action, game)` with `ActionExecutor().execute(action, game, player)`.
   - Replace every `game.resources[...]`/`game.buildings[...]`/etc. read/write in assertions with `player.<field>`.
3. **Update the shared helper** (`collect_treasure_action_helper.dart`)
   - If it exposes a `buildGameWithTreasure(...)` builder, adapt it to also return (or accept) a `Player` with the appropriate resources and revealedCells so tests can pre-seed "the cell is revealed for this player".
4. **Add new assertion to `collect_treasure_action_execute_test.dart`**
   - After a successful collect, assert that `game.gameMap!.cellAt(x, y).collectedBy == player.id`.
5. **Add new assertion to `collect_treasure_action_validate_test.dart`**
   - "Déjà collecté" failure when `collectedBy` is set, even if the caller's id matches (the action refuses double-collect unconditionally — SPEC §US-08).

## Dependencies

- Tasks 06–11 (actions accept a Player and read per-player state).
- Task 19 (test helpers for constructing players are available if shared).

## Test Plan

Running `flutter test test/domain/action/` should pass after this task.

## Notes

- Many tests will become shorter because the `Game` no longer needs default resource/building seeding — the `Player` takes care of it.
- The `collect_treasure_action_helper.dart` was specifically designed to build a `Game` with a treasure in place; extend rather than rewrite it.
