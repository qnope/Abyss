# Task 13 - FightMonsterResult

## Summary

Custom `ActionResult` returned by the upcoming `FightMonsterAction`.
Carries everything the presentation layer needs to render the
post-fight summary screen: the raw `FightResult` from the engine, the
loot map (empty on defeat), and the per-`UnitType` accounting of
sent / survived intact / wounded / dead.

## Implementation steps

1. Create `lib/domain/action/fight_monster_result.dart`:
   - Class `FightMonsterResult extends ActionResult`.
   - Final fields:
     - `bool victory`
     - `FightResult? fight` (null when validation failed)
     - `Map<ResourceType, int> loot` (empty on defeat or failure)
     - `Map<UnitType, int> sent`
     - `Map<UnitType, int> survivorsIntact`
     - `Map<UnitType, int> wounded`
     - `Map<UnitType, int> dead`
   - Named constructors:
     - `FightMonsterResult.success({required this.victory, required this.fight, required this.loot, required this.sent, required this.survivorsIntact, required this.wounded, required this.dead}) : super.success();`
     - `const FightMonsterResult.failure(String reason) : victory = false, fight = null, loot = const {}, sent = const {}, survivorsIntact = const {}, wounded = const {}, dead = const {}, super.failure(reason);`

## Dependencies

- **Internal**: `ActionResult`, `FightResult` (Task 08),
  `ResourceType`, `UnitType`.
- **External**: none.

## Test plan

- New `test/domain/action/fight_monster_result_test.dart`:
  - `failure('reason')` -> `isSuccess == false`, all maps empty,
    `fight == null`, `victory == false`.
  - `success(...)` -> `isSuccess == true`, all fields preserved,
    `victory` matches the argument.

## Notes

- File target: < 60 lines.
- Mirrors the existing `CollectTreasureResult` pattern.
