# Dependency Graph — Production Buildings

## Task Order

```
Task 01: Add BuildingType enum values
   │
   ├──→ Task 02: Update BuildingCostCalculator
   │       │
   │       ├──→ Task 03: Update UpgradeBuildingAction (production bonus)
   │       │
   │       └──→ Task 06: Test BuildingCostCalculator
   │
   ├──→ Task 04: Update Game.defaultBuildings()
   │
   ├──→ Task 05: Update BuildingTypeExtensions
   │
   └──→ (All downstream tasks)

Task 03 ──→ Task 07: Test UpgradeBuildingAction + production bonus

Task 04 + 05 ──→ Task 08: Widget tests

Task 01–08 ──→ Task 09: Regression check
```

## Dependency Table

| Task | Depends on |
|------|-----------|
| 01 — BuildingType enum | — |
| 02 — BuildingCostCalculator | 01 |
| 03 — UpgradeBuildingAction | 01, 02 |
| 04 — Game.defaultBuildings() | 01 |
| 05 — BuildingTypeExtensions | 01 |
| 06 — Test BuildingCostCalculator | 01, 02 |
| 07 — Test UpgradeBuildingAction | 01, 02, 03 |
| 08 — Widget tests | 01, 02, 04, 05 |
| 09 — Regression check | 01–08 |

## Parallelism

After Task 01:
- Tasks 02, 04, 05 can run **in parallel**.

After Task 02:
- Tasks 03, 06 can run **in parallel** (and parallel with 04, 05 if still running).

After Task 03:
- Task 07 can start.

After Tasks 04 + 05:
- Task 08 can start.

Task 09 runs last, after everything else.

## Notes

- No UI widget code changes are needed — the existing `BuildingListView`, `BuildingDetailSheet`, and `UpgradeSection` are driven by `BuildingCostCalculator` and `BuildingTypeExtensions`. Adding new switch cases is sufficient.
- SVG icon assets already exist at `assets/icons/buildings/`.
- No new files need to be created — all changes are additions to existing files and tests.
