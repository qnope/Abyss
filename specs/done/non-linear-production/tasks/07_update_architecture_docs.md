# Task 07 — Update architecture docs

## Summary

Update the architecture documentation to reflect the new production formula system and the removal of `productionPerLevel`.

## Implementation Steps

### 1. Edit `specs/architecture/building_system.md`

- Remove `productionPerLevel(type) → MapEntry<ResourceType, int>?` from the `BuildingCostCalculator` domain model block.
- Replace the sentence "Each upgrade adds a flat `productionPerLevel` bonus to the associated resource." with "Production per turn is computed by `ProductionFormula` (see resource_system.md)."
- Remove the "Per level" column from the production buildings table.
- Add `production_formula.dart` and `production_formulas.dart` to the file structure section under `lib/domain/`.

### 2. Edit `specs/architecture/resource_system.md`

- Update the "Dynamic production" design decision to mention `ProductionFormula` and `productionFormulas` instead of just `ProductionCalculator.fromBuildings()`.
- Add `production_formula.dart` and `production_formulas.dart` to the file structure section under `lib/domain/`.

## Dependencies

- Tasks 01–06 (all code changes complete).

## Test Plan

- No code tests — documentation only.
- Verify the docs are consistent with the new code by reviewing the file structure section against actual files.
