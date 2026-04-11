# Task 32: Integration Test — Full Transition Flow

## Summary
End-to-end integration test covering the complete transition flow: discover faille → build module → assault → capture → descend → explore Level 2 → reinforce.

## Implementation Steps

1. **Create test file** `test/integration/transition_flow_test.dart`:

2. **Test: Full assault flow**:
   ```
   1. Create game with seeded map (known faille positions)
   2. Reveal a faille tile (add to revealedCells)
   3. Build descentModule (level 0 → 1)
   4. Recruit army with abyssAdmiral + combat units
   5. Execute AttackTransitionBaseAction
   6. Verify faille captured
   7. Execute DescendAction with selected units
   8. Verify Level 2 map generated
   9. Verify units on Level 2
   10. End turn to advance
   ```

3. **Test: Failed assault recovery**:
   ```
   1. Create game with weak army
   2. Attack faille → defeat
   3. Verify army lost, faille still neutral
   4. Recruit new army
   5. Attack again → victory (stronger army)
   6. Verify capture
   ```

4. **Test: Multi-level resource sharing**:
   ```
   1. Complete descent to Level 2
   2. Verify resources on Level 1 still produce
   3. End turn
   4. Verify production applied to global pool
   5. Verify unit consumption includes Level 2 units
   ```

5. **Test: Reinforcement pipeline**:
   ```
   1. Complete descent to Level 2
   2. Recruit more units on Level 1
   3. SendReinforcements through faille
   4. Verify units removed from Level 1
   5. End turn
   6. Verify units arrived on Level 2
   ```

## Dependencies
- **Internal**: All previous tasks (this is the final validation)
- **External**: None

## Test Plan
- Self — this IS the test task
- Run `flutter test test/integration/transition_flow_test.dart`

## Notes
- Use seeded Random for deterministic map generation and combat.
- This test validates the entire feature works end-to-end at the domain level (no UI).
- If the test file exceeds 150 lines, split into multiple test files by scenario.
