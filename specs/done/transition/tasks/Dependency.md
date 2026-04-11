# Dependency Graph — Transition Feature

## Phase 1: Foundational Refactors (Tasks 01-06)

```
01 Rename siphoner → abyssAdmiral
 └─► 02 Player.unitsPerLevel model
      └─► 03 Update domain actions
           └─► 04 Update calculators & TurnResolver
                └─► 05 Update presentation
                     └─► 06 Game.levels multi-level maps
```

**Rationale**: Each refactor builds on the previous. The rename is standalone. Player model change must happen before domain/presentation code can be updated. Game model change is last because it depends on Player being multi-level-ready.

## Phase 2: New Domain Models (Tasks 07-10)

```
06 ─► 07 TransitionBase model
      07 ─► 08 isBoss + GuardianFactory
      06 ─► 09 Descent buildings
      02 ─► 10 ReinforcementOrder model
```

**Rationale**: All new models depend on the refactored Game/Player models. Tasks 07-10 are mostly independent of each other (can be partially parallelized).

## Phase 3: Map Generation (Tasks 11-12)

```
07 ─► 11 TransitionBasePlacer
      11 ─► 12 Integrate in MapGenerator
```

## Phase 4: Domain Actions (Tasks 13-17)

```
07 + 08 + 09 + 06 ─► 13 AttackTransitionBaseAction
07 + 06 + 02 + 12 ─► 14 DescendAction
10 + 07 + 02      ─► 15 SendReinforcementsAction
13 + 14 + 15       ─► 16 Register ActionTypes
10 + 02 + 04       ─► 17 TurnResolver reinforcements
```

## Phase 5: History & Data (Tasks 18-19)

```
16 + 13-15 ─► 18 Transition history entries
07 + 10 + 18 ─► 19 Register Hive adapters
```

## Phase 6: Presentation (Tasks 20-27)

```
07 + 09 + 16 + 18 ─► 20 Display extensions
                      ─► 21 LevelSelector widget (standalone)
07                 ─► 22 Transition base map rendering
07 + 09 + 20       ─► 23 TransitionBase bottom sheet
02 + 07             ─► 24 Descent dialog
02 + 07             ─► 25 Reinforcement dialog
21 + 06 + 05        ─► 26 GameScreen level switching
13-15 + 23-25 + 26  ─► 27 GameScreen transition action handlers
```

## Phase 7: Tests (Tasks 28-32)

```
11 + 12 ─► 28 Tests: placement
08 + 13 ─► 29 Tests: boss combat & capture
14 + 15 + 17 ─► 30 Tests: descent & reinforcement
01 + 09 ─► 31 Tests: buildings & rename
All ─► 32 Integration test: full flow
```

## Summary: Critical Path

```
01 → 02 → 03 → 04 → 05 → 06 → 07 → 08 → 13 → 16 → 18 → 19 → 20 → 23 → 27 → 32
                                  ├── 11 → 12 → 14 ──┘
                                  ├── 09 ─────────────┘
                                  └── 10 → 15 → 17 ──┘
```

The critical path runs through the foundational refactors (01-06), then the domain model (07-08), and converges at the action registration (16) before flowing into presentation and tests.

## Parallelization Opportunities

- **Tasks 07, 09, 10**: Can run in parallel after Task 06
- **Tasks 11, 08**: Can run in parallel (both depend on 07)
- **Tasks 21, 22, 24, 25**: Can run in parallel (independent widgets)
- **Tasks 28, 29, 30, 31**: Can run in parallel (independent test suites)
