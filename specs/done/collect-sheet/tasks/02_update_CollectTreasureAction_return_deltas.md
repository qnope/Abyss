# Task 02 — Update CollectTreasureAction to return deltas and rebalance ruins

## Summary

Modify `CollectTreasureAction.execute` so it:
1. Tracks the **actual delta** added to each resource (post-clamp at `maxStorage`).
2. Returns a `CollectTreasureResult.success(deltas)` instead of a bare `ActionResult.success()`.
3. Uses the **new ruins reward ranges** from the SPEC.

The `validate()` method and the `resourceBonus` reward ranges are unchanged.

## Implementation Steps

1. **Edit `lib/domain/action/collect_treasure_action.dart`**

   - Add import: `import 'collect_treasure_result.dart';`
   - Change the return types of `validate` and `execute` so the failure path also returns a `CollectTreasureResult`. (Both methods still declare `ActionResult` as the return type — the contract from the base class — but the concrete returned values are `CollectTreasureResult.success(...)` / `CollectTreasureResult.failure(...)`.)

2. **Refactor `_addResource` to return the delta**

   ```dart
   int _addResource(Game game, ResourceType type, int amount) {
     final resource = game.resources[type]!;
     final before = resource.amount;
     resource.amount = (resource.amount + amount).clamp(0, resource.maxStorage);
     return resource.amount - before;
   }
   ```

3. **Aggregate deltas inside `execute`**

   ```dart
   final deltas = <ResourceType, int>{};
   if (cell.content == CellContentType.resourceBonus) {
     deltas[ResourceType.algae] = _addResource(game, ResourceType.algae, 50 + _random.nextInt(51));
     deltas[ResourceType.coral] = _addResource(game, ResourceType.coral, 30 + _random.nextInt(21));
     deltas[ResourceType.ore]   = _addResource(game, ResourceType.ore,   30 + _random.nextInt(21));
   } else if (cell.content == CellContentType.ruins) {
     deltas[ResourceType.algae] = _addResource(game, ResourceType.algae, _random.nextInt(101));
     deltas[ResourceType.coral] = _addResource(game, ResourceType.coral, _random.nextInt(26));
     deltas[ResourceType.ore]   = _addResource(game, ResourceType.ore,   _random.nextInt(26));
     deltas[ResourceType.pearl] = _addResource(game, ResourceType.pearl, _random.nextInt(3));
   }
   ```

   - Drop the existing private helpers `_collectResourceBonus` and `_collectRuins` (replaced by inline blocks above) **or** keep them but have them return `Map<ResourceType, int>`. Pick whichever keeps the file shortest while staying under 150 lines.

4. **Return the result**

   ```dart
   game.gameMap!.setCell(targetX, targetY, cell.copyWith(isCollected: true));
   return CollectTreasureResult.success(deltas);
   ```

5. **Update failure paths**
   - All current `return const ActionResult.failure('…')` lines become `return const CollectTreasureResult.failure('…')`. The validation strings are unchanged.

6. **Verify ruins ranges** (SPEC US-3):
   - Algae: `_random.nextInt(101)` → `[0, 100]`
   - Coral: `_random.nextInt(26)` → `[0, 25]`
   - Ore: `_random.nextInt(26)` → `[0, 25]`
   - Pearl: `_random.nextInt(3)` → `[0, 2]` (unchanged)

## Dependencies

- Task 01 (`CollectTreasureResult` must exist).

## Test Plan

- Tests live in Task 03 (existing test file is updated there).

## Notes

- The action's existing behavior (validation rules, marking the cell as collected, taking an injectable `Random`) is unchanged.
- File must remain under 150 lines — current file is 83 lines, the changes add ~15 lines.
- **Important:** previously, ruins gave coral / ore / pearl in `[0, 2]` and **no algae**. The new behavior adds algae and widens coral/ore. Existing tests in `collect_treasure_action_execute_test.dart` will break and are updated in Task 03.
