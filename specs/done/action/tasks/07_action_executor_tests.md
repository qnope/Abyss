# Task 07 — Test ActionExecutor

## Summary

Write unit tests for `ActionExecutor` and integration tests for the full action flow.

## Implementation Steps

1. Create `test/domain/action_executor_test.dart`
2. Write unit tests using `UpgradeBuildingAction` as the concrete action

## Dependencies

- Task 04 (`UpgradeBuildingAction`)
- Task 06 (`ActionExecutor`)
- Existing: `Game`, `Player`, `Building`, `BuildingType`, `Resource`, `ResourceType`

## Test Plan

**File**: `test/domain/action_executor_test.dart`

### Group: ActionExecutor
- Execute valid UpgradeBuildingAction: resources deducted, level incremented, returns success
- Execute UpgradeBuildingAction with insufficient resources: returns failure with reason, game unchanged
- Execute UpgradeBuildingAction at max level: returns failure with reason, game unchanged

### Group: Integration — full flow
- Create action → execute via executor → verify game state after (resources deducted, level changed)
- Same action, same game structure → same result regardless of "who" calls it (simulates player vs AI parity)

## Notes

- Integration tests verify the full pipeline: action creation → executor → game mutation.
- The "player vs AI parity" test creates the same UpgradeBuildingAction for two separate Game instances with identical state and verifies identical outcomes.
