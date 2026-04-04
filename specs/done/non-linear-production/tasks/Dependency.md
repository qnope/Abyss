# Dependency Graph — non-linear-production

## Task List

| # | Task | Depends on |
|---|---|---|
| 01 | Create ProductionFormula class | — |
| 02 | Create production formulas registry | 01 |
| 03 | Update ProductionCalculator | 01, 02 |
| 04 | Update ProductionCalculator tests | 03 |
| 05 | Update upgrade action production tests | 03 |
| 06 | Remove productionPerLevel | 03 |
| 07 | Update architecture docs | 01–06 |
| 08 | Final validation | 01–07 |

## Execution Order

```
01 → 02 → 03 → [04, 05, 06] (parallel) → 07 → 08
```

Tasks 04, 05, and 06 are independent of each other and can run in parallel once task 03 is complete.
