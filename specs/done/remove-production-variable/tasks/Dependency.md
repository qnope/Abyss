# Dependency Graph

## Execution Order

```
Task 01  (ProductionCalculator)
   |
   v
Task 02  (Remove field from Resource + Game)
   |
   +---> Task 03  (Remove mutation from UpgradeBuildingAction)
   |
   +---> Task 04  (Update ResourceBarItem)
   |
   +---> Task 05  (Update ResourceDetailSheet)
            |
            v
         Task 06  (Update ResourceBar) <--- Task 04
            |
            v
         Task 07  (Update GameScreen) <--- Task 01
            |
            v
         Task 08  (Update domain tests) <--- Tasks 01, 02, 03
            |
         Task 09  (Update widget tests) <--- Tasks 02, 04, 06
            |
         Task 10  (Update architecture docs)
            |
            v
         Task 11  (Final verification)
```

## Summary Table

| Task | Depends on |
|------|-----------|
| 01 — ProductionCalculator | — |
| 02 — Remove from Resource + Game | — |
| 03 — Remove from UpgradeBuildingAction | 02 |
| 04 — Update ResourceBarItem | 02 |
| 05 — Update ResourceDetailSheet | 02 |
| 06 — Update ResourceBar | 04, 05 |
| 07 — Update GameScreen | 01, 06 |
| 08 — Update domain tests | 01, 02, 03 |
| 09 — Update widget tests | 02, 04, 06 |
| 10 — Update architecture docs | 01 |
| 11 — Final verification | all |

## Recommended sequential execution

01 → 02 → 03 → 04 → 05 → 06 → 07 → 08 → 09 → 10 → 11
