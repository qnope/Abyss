# Non-Linear Production - Feature Specification

## 1. Feature Overview

Replace the current linear production formula (`level * basePerLevel`) with a configurable formula system. Each building defines its own production function `(int level) → int`, allowing non-linear growth curves (quadratic, logarithmic, etc.).

The production logic moves out of `BuildingCostCalculator` into a dedicated class, separating cost concerns from production concerns.

## 2. API Design

### ProductionFormula

A new class that encapsulates the production configuration for a single building type:

- `resourceType`: the resource produced by this building
- `compute(int level)`: returns the production amount for a given level

Each building type maps to one `ProductionFormula` (or none, for non-producing buildings like headquarters). A building produces exactly one resource type.

### ProductionCalculator

The existing `ProductionCalculator` class is updated to use `ProductionFormula` instead of `BuildingCostCalculator.productionPerLevel`. It no longer performs `level * basePerLevel` itself — it delegates to the formula's `compute` function.

### Removal of productionPerLevel

The static method `BuildingCostCalculator.productionPerLevel` is removed. All production logic is handled by the new formula system.

### Production Formulas

| Building | Resource | Formula | L1 | L2 | L3 | L4 | L5 |
|---|---|---|---|---|---|---|---|
| AlgaeFarm | algae | `3 * level² + 2` | 5 | 14 | 29 | 50 | 77 |
| CoralMine | coral | `2 * level² + 2` | 4 | 10 | 20 | 34 | 52 |
| OreExtractor | ore | `2 * level² + 1` | 3 | 9 | 19 | 33 | 51 |
| SolarPanel | energy | `2 * level² + 1` | 3 | 9 | 19 | 33 | 51 |

Headquarters has no production formula.

## 3. Testing and Validation

### Unit tests

- Each formula returns the expected values for levels 1 through 5.
- `ProductionCalculator.fromBuildings` correctly computes total production using the new formulas.
- Buildings with level 0 produce nothing.
- Headquarters returns no production.

### Regression

- All existing tests that depend on production values are updated to reflect the new non-linear values.
- `flutter analyze` and `flutter test` pass with zero errors.
