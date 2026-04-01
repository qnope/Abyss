# Dependency Graph — Base Buildings

## Overview

15 tasks organized in 3 phases: Domain, Presentation, and Testing.

## Dependency Diagram

```
Phase 1: Domain Layer
━━━━━━━━━━━━━━━━━━━━━

  01 BuildingType enum ──┬──→ 03 Generate Hive adapters
  02 Building model ─────┘            │
                                      ↓
  04 CostCalculator ──→ 05 UpgradeCheck ──→ 06 Wire into Game
                                                    │
                                                    ↓
                                            07 Domain tests


Phase 2: Presentation Layer
━━━━━━━━━━━━━━━━━━━━━━━━━━━

  08 BuildingType extensions ──→ 09 BuildingIcon ──→ 10 BuildingCard ──→ 11 BuildingListView
                                       │                                        │
                                       ↓                                        ↓
                                 13 UpgradeSection ──→ 12 BuildingDetailSheet ──→ 14 Wire GameScreen


Phase 3: Testing
━━━━━━━━━━━━━━━━

  07 Domain tests
       ↓
  15 Widget tests (depends on all presentation tasks 09–14)
```

## Task Dependency Table

| Task | Depends on |
|------|-----------|
| 01 BuildingType enum | — |
| 02 Building model | 01 |
| 03 Generate Hive adapters | 01, 02 |
| 04 BuildingCostCalculator | 01 |
| 05 UpgradeCheck model | 02, 04 |
| 06 Wire into Game + Repository | 01, 02, 03 |
| 07 Domain unit tests | 01–06 |
| 08 BuildingType extensions | 01 |
| 09 BuildingIcon widget | 01, 08 |
| 10 BuildingCard widget | 02, 08, 09 |
| 11 BuildingListView widget | 02, 10 |
| 12 BuildingDetailSheet widget | 02, 08, 09, 13 |
| 13 UpgradeSection widget | 02, 04, 05, 08 |
| 14 Wire GameScreen | 04, 06, 11, 12 |
| 15 Widget tests | 07, 09–14 |

## Parallelization Opportunities

- **Tasks 01 + 04**: BuildingType and CostCalculator can start simultaneously (04 only needs enum, not model)
- **Tasks 08 + 06**: Extensions and Game wiring can run in parallel after tasks 01-03
- **Tasks 10 + 13**: BuildingCard and UpgradeSection can be built in parallel
- **Tasks 11 + 12**: BuildingListView and BuildingDetailSheet can be built in parallel (once their deps are met)

## Estimated Execution Order

Sequential optimal path: 01 → 02 → 03 → 04 → 05 → 06 → 07 → 08 → 09 → 10 → 13 → 11/12 → 14 → 15
