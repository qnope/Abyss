# Task 14 — Domain Unit Tests

## Summary

Write unit tests for all new domain classes: models, calculator, actions, and production bonus.

## Implementation Steps

### 1. Create `test/domain/tech_branch_state_test.dart`

- Test default construction: `unlocked == false`, `researchLevel == 0`.
- Test construction with values: `unlocked = true`, `researchLevel = 3`.

### 2. Create `test/domain/tech_cost_calculator_test.dart`

**Group: unlockCost**
- Test military: `{ore: 30, energy: 20}`.
- Test resources: `{coral: 30, algae: 20}`.
- Test explorer: `{energy: 30, ore: 20}`.

**Group: researchCost**
- For each branch, test levels 1–5 return correct resource amounts.
- Test that pearl is included only at levels 4 and 5.

**Group: requiredLabLevel**
- Test levels 1–5 → returns 1, 2, 3, 4, 5.

**Group: checkUnlock**
- Test success: lab level 1, branch locked, resources sufficient.
- Test fail: lab level 0 → `canAct == false`.
- Test fail: branch already unlocked → `canAct == false`.
- Test fail: insufficient resources → `missingResources` populated.

**Group: checkResearch**
- Test success: branch unlocked, level 0→1, lab level 1, resources sufficient.
- Test fail: branch locked → `branchLocked == true`.
- Test fail: previous node not researched (skip level) → `previousNodeMissing == true`.
- Test fail: lab level too low → `requiredLabLevel` and `currentLabLevel` populated.
- Test fail: max level reached → `isMaxLevel == true`.
- Test fail: insufficient resources → `missingResources` populated.

### 3. Create `test/domain/unlock_branch_action_test.dart`

Use `makeGame()` helper (like existing action tests):

```dart
Game makeGame({
  int labLevel = 1,
  int ore = 100, int energy = 100,
  int coral = 100, int algae = 100,
  bool militaryUnlocked = false,
}) { ... }
```

**Group: validate**
- Success case.
- Lab not built → failure.
- Branch already unlocked → failure.
- Insufficient resources → failure.

**Group: execute**
- Success: resources deducted, branch.unlocked == true.
- Failure: game state unchanged.

### 4. Create `test/domain/research_tech_action_test.dart`

**Group: validate**
- Success case (branch unlocked, lab level OK, resources OK).
- Branch locked → failure.
- Max level reached → failure.
- Lab level too low → failure.
- Insufficient resources → failure.

**Group: execute**
- Success: resources deducted, researchLevel incremented.
- Failure: game state unchanged.

### 5. Update `test/domain/production_calculator_test.dart`

Add a group **"with tech branches"**:
- No tech branches (null) → same as before.
- Resources branch level 1 → production * 1.2 (floored).
- Resources branch level 5 → production * 2.0.
- Military branch level 3 → no effect on production.
- Unlocked but level 0 → no effect.

### 6. Update `test/domain/game_test.dart`

- Test `Game()` includes `techBranches` with 3 entries.
- Test `defaultTechBranches()` returns all branches locked at level 0.

## Files

| Action | Path |
|--------|------|
| Create | `test/domain/tech_branch_state_test.dart` |
| Create | `test/domain/tech_cost_calculator_test.dart` |
| Create | `test/domain/unlock_branch_action_test.dart` |
| Create | `test/domain/research_tech_action_test.dart` |
| Edit | `test/domain/production_calculator_test.dart` |
| Edit | `test/domain/game_test.dart` |

## Dependencies

- Tasks 01–07 (all domain code must be written first).

## Test Plan

- Run `flutter test test/domain/` — all green.
