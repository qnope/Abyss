# Task 03 — Update CollectTreasureAction execute tests

## Summary

Update the existing execute tests so they:
1. Cover the **new ruins reward ranges** (algae 0-100, coral 0-25, ore 0-25, pearl 0-2).
2. Verify the action returns a `CollectTreasureResult` with the correct **per-resource deltas**.
3. Verify the deltas are **clamped** to what was actually applied when the stock is at `maxStorage`.

The validate tests (`collect_treasure_action_validate_test.dart`) require no behavior changes, only updating the failure path to assert against the new failure type if needed.

## Implementation Steps

1. **Edit `test/domain/action/collect_treasure_action_execute_test.dart`**

2. **Update `resourceBonus adds algae, coral and ore`**
   - With `Random(42)`, recompute the expected `nextInt(51)`, `nextInt(21)`, `nextInt(21)` values (the existing test already does this — keep them; the resourceBonus formula is unchanged).
   - Cast result: `final result = action.execute(game) as CollectTreasureResult;`
   - Assert `result.deltas[ResourceType.algae]`, `[coral]`, `[ore]` equal the rolled amounts.
   - Assert `result.deltas` does NOT contain `ResourceType.pearl` (or contains a `0`/missing entry — choose one and stay consistent with task 02; recommended: missing for resourceBonus).

3. **Update `ruins adds coral, ore and pearl` → rename to `ruins adds algae, coral, ore and pearl`**
   - With `Random(42)`, recompute: `nextInt(101)`, `nextInt(26)`, `nextInt(26)`, `nextInt(3)` values.
   - Cast result to `CollectTreasureResult`.
   - Assert deltas for all four resources.

4. **Update `ruins amounts stay between 0 and 2`** → rename to `ruins amounts stay within new ranges`
   - Loop `seed = 0..49`.
   - Algae gain: `inInclusiveRange(0, 100)`.
   - Coral gain: `inInclusiveRange(0, 25)`.
   - Ore gain: `inInclusiveRange(0, 25)`.
   - Pearl gain: `inInclusiveRange(0, 2)`.

5. **Add `ruins min and max are reachable`**
   - Iterate seeds (e.g. `0..199`) and confirm at least one seed yields the maximum (100/25/25/2) and at least one yields the minimum (0) for each resource. If a small seed range can't hit both ends, document the seed used or widen the range.
   - Alternative if reaching min/max via real `Random` is flaky: inject a deterministic stub `Random` (subclass with overridden `nextInt`) — but stay simple if `Random(seed)` works.

6. **Add `resourceBonus returns deltas matching applied amounts`**
   - Already largely covered by step 2; ensure delta values equal `final amount - initial amount`.

7. **Add `resourceBonus delta is clamped at maxStorage`**
   - Pre-fill `algae.amount = 4990` (maxStorage = 5000).
   - Execute action.
   - Cast result; assert `result.deltas[ResourceType.algae] <= 10` and equals `5000 - 4990`.
   - Verify `game.resources[ResourceType.algae].amount == 5000`.

8. **Add `ruins delta is clamped at maxStorage when resource full`**
   - Pre-fill all four resources at `maxStorage`.
   - Execute action with any seed.
   - Assert all deltas equal `0`.

9. **Update `resourceBonus caps resources at maxStorage`** (existing test)
   - Already correct; just additionally cast and check `result.deltas` reflect the actual cap.

10. **Update `marks cell as collected after ruins`** if needed (existing test passes a `Random(42)` that may now produce different rolls, but the test only checks `isCollected == true`, so it should keep passing).

## Dependencies

- Task 02 (`CollectTreasureAction` returns `CollectTreasureResult` and uses new ranges).

## Test Plan

- Run `flutter test test/domain/action/collect_treasure_action_execute_test.dart`.
- All tests must pass.

## Notes

- Test file currently has 142 lines. Keep it under 150 by trimming any redundant cases. If it grows, split clamping cases into a separate `collect_treasure_action_clamp_test.dart`.
- Validate tests (`collect_treasure_action_validate_test.dart`) — read first; if they currently assert `result is ActionResult` only, no changes needed. If they cast to a specific type, update the cast.
