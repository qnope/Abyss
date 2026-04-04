# Dependency Graph — add-army

## Layer 0: Domain Model Basics (no dependencies)

- **Task 01** — UnitType enum + UnitStats

## Layer 1: Domain Models (depends on Layer 0)

- **Task 02** — Unit Hive model → depends on Task 01
- **Task 03** — UnitCostCalculator → depends on Task 01

## Layer 2: Game Integration (depends on Layers 0-1)

- **Task 04** — Update Game + ActionType + build_runner → depends on Tasks 01, 02

## Layer 3: Domain Logic (depends on Layer 2)

- **Task 05** — RecruitUnitAction → depends on Tasks 01, 03, 04
- **Task 06** — Update TurnResolver → depends on Task 04

## Layer 4: Presentation Extensions (depends on Layer 0)

- **Task 07** — UnitTypeExtensions → depends on Task 01

## Layer 5: Presentation Widgets (depends on Layers 0-4)

- **Task 08** — UnitIcon → depends on Task 07
- **Task 09** — UnitCard → depends on Tasks 07, 08
- **Task 10** — ArmyListView → depends on Tasks 02, 03, 09
- **Task 11** — UnitDetailSheet → depends on Tasks 01, 03, 07, 08, 12
- **Task 12** — RecruitmentSection → depends on Task 03

## Layer 6: Screen Wiring (depends on all above)

- **Task 13** — Wire Army tab in GameScreen → depends on Tasks 05, 10, 11, 12

## Layer 7: Domain Tests (depends on domain tasks)

- **Task 14** — Tests: UnitType, UnitStats, UnitCostCalculator → depends on Tasks 01, 02, 03
- **Task 15** — Tests: RecruitUnitAction, TurnResolver → depends on Tasks 04, 05, 06

## Layer 8: Widget Tests (depends on widget tasks)

- **Task 16** — Tests: UnitCard, ArmyListView, UnitIcon → depends on Tasks 08, 09, 10
- **Task 17** — Tests: UnitDetailSheet, RecruitmentSection → depends on Tasks 11, 12
- **Task 18** — Tests: GameScreen army tab → depends on Task 13

## Execution Order

```
01 ──┬── 02 ──┐
     │        ├── 04 ──┬── 05 ──┐
     ├── 03 ──┤        └── 06   │
     │        │                  │
     └── 07 ──┬── 08 ── 09 ──┐  │
              │               │  │
              ├── 12 ──┐      │  │
              │        ├── 11 │  │
              └────────┘      │  │
                        10 ───┤  │
                              │  │
                        13 ───┘──┘
                         │
              14, 15, 16, 17, 18
```

Tasks 14-18 (tests) can run in parallel once their dependencies are met.
