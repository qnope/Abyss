# Task 06 — Test BuildingCostCalculator for Production Buildings

## Summary
Add unit tests for upgrade costs, max level, prerequisites, and productionPerLevel for all 4 production buildings.

## Implementation Steps

### 1. Edit `test/domain/building_cost_calculator_test.dart`

#### Add to `upgradeCost` group:

**Algae Farm:**
- `'algaeFarm level 0->1: coral=20'` — `upgradeCost(algaeFarm, 0)` → coral: 20
- `'algaeFarm level 2->3: coral=100'` — `upgradeCost(algaeFarm, 2)` → coral: 100 (20*(4+1))
- `'algaeFarm at max level 5: empty'` — `upgradeCost(algaeFarm, 5)` → empty

**Coral Mine:**
- `'coralMine level 0->1: ore=15'` — `upgradeCost(coralMine, 0)` → ore: 15
- `'coralMine level 3->4: ore=150'` — `upgradeCost(coralMine, 3)` → ore: 150 (15*(9+1))

**Ore Extractor:**
- `'oreExtractor level 0->1: coral=25, energy=15'` — both resources
- `'oreExtractor level 1->2: coral=50, energy=30'` — (base*(1+1))

**Solar Panel:**
- `'solarPanel level 0->1: coral=20, ore=15'` — both resources
- `'solarPanel level 4->5: coral=340, ore=255'` — (base*(16+1))

#### Add to `maxLevel` group:
- `'algaeFarm is 5'`, `'coralMine is 5'`, `'oreExtractor is 5'`, `'solarPanel is 5'`

#### Add to `prerequisites` group:
- `'algaeFarm level 1 requires HQ 1'` — prereqs(algaeFarm, 1) → {headquarters: 1}
- `'algaeFarm level 3 requires HQ 4'` — prereqs(algaeFarm, 3) → {headquarters: 4}
- `'algaeFarm level 5 requires HQ 10'` — prereqs(algaeFarm, 5) → {headquarters: 10}
- `'coralMine level 2 requires HQ 2'`
- `'solarPanel level 4 requires HQ 6'`

#### Add to `checkUpgrade` group:
- `'cannot upgrade algaeFarm when HQ prerequisite not met'` — algaeFarm at level 0, HQ at level 0, sufficient resources → canUpgrade false, missingPrerequisites has headquarters: 1
- `'can upgrade algaeFarm when HQ and resources sufficient'` — algaeFarm at level 0, HQ at level 1, sufficient coral → canUpgrade true

#### Add new `productionPerLevel` group:
- `'headquarters returns null'`
- `'algaeFarm returns algae with base 5'`
- `'coralMine returns coral with base 4'`
- `'oreExtractor returns ore with base 3'`
- `'solarPanel returns energy with base 3'`

## Dependencies
- Task 01, Task 02

## Test Plan
- **File**: `test/domain/building_cost_calculator_test.dart`
- Approximately 20 new test cases.
