# Task 04 — TechCostCalculator

## Summary

Create a stateless calculator for tech branch unlock costs, research node costs, lab-level prerequisites, and validation checks. Also create a `TechCheck` result class.

## Implementation Steps

### 1. Create `lib/domain/tech_check.dart`

```dart
class TechCheck {
  final bool canAct;
  final bool isMaxLevel;
  final Map<ResourceType, int> missingResources;
  final int requiredLabLevel;
  final int currentLabLevel;
  final bool branchLocked;
  final bool previousNodeMissing;

  const TechCheck({
    required this.canAct,
    this.isMaxLevel = false,
    this.missingResources = const {},
    this.requiredLabLevel = 0,
    this.currentLabLevel = 0,
    this.branchLocked = false,
    this.previousNodeMissing = false,
  });
}
```

### 2. Create `lib/domain/tech_cost_calculator.dart`

Static methods:

- **`unlockCost(TechBranch branch) → Map<ResourceType, int>`**
  From spec:
  | Branch | Cost |
  |--------|------|
  | military | ore: 30, energy: 20 |
  | resources | coral: 30, algae: 20 |
  | explorer | energy: 30, ore: 20 |

- **`researchCost(TechBranch branch, int level) → Map<ResourceType, int>`**
  From spec tables (level 1–5), per branch. Use a `switch` on branch + level.

  Military (ore + energy + pearl at 4-5):
  | Level | Ore | Energy | Pearl |
  |-------|-----|--------|-------|
  | 1 | 40 | 25 | — |
  | 2 | 80 | 50 | — |
  | 3 | 150 | 90 | — |
  | 4 | 250 | 150 | 5 |
  | 5 | 400 | 250 | 10 |

  Resources (coral + algae + pearl at 4-5):
  | Level | Coral | Algae | Pearl |
  |-------|-------|-------|-------|
  | 1 | 40 | 25 | — |
  | 2 | 80 | 50 | — |
  | 3 | 150 | 90 | — |
  | 4 | 250 | 150 | 5 |
  | 5 | 400 | 250 | 10 |

  Explorer (energy + ore + pearl at 4-5):
  | Level | Energy | Ore | Pearl |
  |-------|--------|-----|-------|
  | 1 | 40 | 25 | — |
  | 2 | 80 | 50 | — |
  | 3 | 150 | 90 | — |
  | 4 | 250 | 150 | 5 |
  | 5 | 400 | 250 | 10 |

- **`requiredLabLevel(int researchLevel) → int`**
  From spec: level 1→1, 2→2, 3→3, 4→4, 5→5 (lab level == research level).

- **`maxResearchLevel` = 5** (constant).

- **`checkUnlock({branch, resources, buildings, techBranches}) → TechCheck`**
  Validates: lab level >= 1, branch not already unlocked, resources sufficient.

- **`checkResearch({branch, targetLevel, resources, buildings, techBranches}) → TechCheck`**
  Validates: branch unlocked, previous node researched, lab level >= targetLevel, resources sufficient, not max level.

## Files

| Action | Path |
|--------|------|
| Create | `lib/domain/tech_check.dart` |
| Create | `lib/domain/tech_cost_calculator.dart` |

## Dependencies

- Task 01 (`TechBranch`).
- Task 02 (`TechBranchState`).
- Reads `BuildingType`, `Building`, `Resource`, `ResourceType` from existing domain.

## Design Notes

- Follow the same stateless pattern as `BuildingCostCalculator`.
- Use exhaustive `switch` on `TechBranch` to force compile-time updates if branches change.
- All methods are `static` — no instance needed.

## Test Plan

- **File:** `test/domain/tech_cost_calculator_test.dart`
- Test `unlockCost` for all 3 branches — correct resource types and amounts.
- Test `researchCost` for all branches, levels 1–5 — correct amounts, pearl at 4-5 only.
- Test `requiredLabLevel` for levels 1–5.
- Test `checkUnlock`: lab not built → fails, branch already unlocked → fails, insufficient resources → fails with correct `missingResources`, success case.
- Test `checkResearch`: branch locked → fails, previous node missing → fails, lab too low → fails, resources insufficient → fails, success case, max level → fails.
- Covered in task 14.
