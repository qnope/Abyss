# Dependency Graph — add-tech

## Layers

```
Domain (01–07) → Presentation (08–13) → Tests (14–15) → Validation (16)
```

## Task Dependencies

| Task | Depends on | Description |
|------|-----------|-------------|
| 01 | — | TechBranch enum |
| 02 | 01 | TechBranchState model |
| 03 | 01, 02 | Integrate into Game + Hive adapters |
| 04 | 01, 02 | TechCostCalculator + TechCheck |
| 05 | 01, 03, 04 | UnlockBranchAction |
| 06 | 01, 03, 04, 05* | ResearchTechAction |
| 07 | 01, 02, 03 | Tech production bonus |
| 08 | 01 | TechBranch extensions |
| 09 | 08 | TechNodeWidget |
| 10 | 02, 08, 09 | TechTreeView |
| 11 | 04, 08 | TechBranchDetailSheet |
| 12 | 04, 08 | TechNodeDetailSheet |
| 13 | 05, 06, 10, 11, 12 | Wire Tech tab in GameScreen |
| 14 | 01–07 | Domain unit tests |
| 15 | 08–13, 14 | Widget tests |
| 16 | 01–15 | Final validation |

*Task 06 depends on 05 only for `ActionType` enum update (done in 05).

## Parallel Execution Opportunities

These groups can be worked in parallel within each layer:

**Domain layer (after 01+02):**
- 03, 04 can run in parallel
- 05, 06, 07 can run in parallel (after 03+04)

**Presentation layer (after 08):**
- 09, 11, 12 can run in parallel
- 10 depends on 09

**Cross-layer:**
- 08 can start as soon as 01 is done (no need to wait for 03–07)

## Critical Path

```
01 → 02 → 03 → 04 → 05 → 06 → 13 → 15 → 16
                ↘ 07
01 → 08 → 09 → 10 ↗ 13
         ↘ 11, 12 ↗
```

Longest path: 01 → 02 → 03 → 04 → 05 → 06 → 13 → 15 → 16 (9 steps).
