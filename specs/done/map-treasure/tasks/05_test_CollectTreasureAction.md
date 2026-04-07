# Task 05 — Test CollectTreasureAction

## Summary

Write unit tests for `CollectTreasureAction` covering both resourceBonus and ruins collection, validation failures, and edge cases.

## Implementation Steps

1. **Create `test/domain/action/collect_treasure_action_validate_test.dart`**

   Test validation failures:
   - `'fails when map is null'` — game with no map → failure `'Carte non générée'`
   - `'fails when cell is not revealed'` — unrevealed cell → failure `'Case non révélée'`
   - `'fails when cell is already collected'` — cell with `isCollected: true` → failure `'Déjà collecté'`
   - `'fails when cell is empty'` — empty cell → failure `'Rien à collecter'`
   - `'fails when cell is monsterLair'` — monster cell → failure `'Rien à collecter'`
   - `'succeeds for resourceBonus'` — revealed, uncollected resourceBonus → success
   - `'succeeds for ruins'` — revealed, uncollected ruins → success

2. **Create `test/domain/action/collect_treasure_action_execute_test.dart`**

   Test execution:
   - `'adds bonus resources to player stock'` — resourceBonus with coral/30 → coral increases by 30
   - `'caps resources at maxStorage'` — set amount near max, collect → capped at maxStorage
   - `'marks cell as collected after resourceBonus'` — cell.isCollected becomes true
   - `'ruins adds random resources and pearls'` — use seeded Random, verify resource + pearl amounts
   - `'marks cell as collected after ruins'` — cell.isCollected becomes true
   - `'collecting already-collected cell fails'` — execute twice → second returns failure

## Dependencies

- Task 03 (CollectTreasureAction)
- Task 04 (test helper)

## Test Plan

- Run `flutter test test/domain/action/collect_treasure_action_validate_test.dart`
- Run `flutter test test/domain/action/collect_treasure_action_execute_test.dart`

## Notes

- Use `Random(42)` (or similar fixed seed) for deterministic ruins tests.
- Verify exact resource amounts after collection.
