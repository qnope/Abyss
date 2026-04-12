# Task Dependencies

## Dependency Graph

```
Phase 1: Hive Models
  01 ─┐
  02 ─┼─→ 04 (build_runner)
  03 ─┘

Phase 2: Map & Combat
  04 → 05 (volcanic kernel placer)
  -- → 06 (guardian factory — no Hive dependency)

Phase 3: Building System
  04 → 07 (building costs)
  07 → 08 (prerequisites + upgrade check)
  04 → 09 (kernel capture helper)
  04 → 10 (deactivator + UI extensions)

Phase 4: Actions & Game Logic
  06, 09 → 11 (attack action)
  02, 03 → 12 (victory checker)
  -- → 13 (game statistics — uses existing types)

Phase 5: Presentation
  11 → 14 (map cell interaction)
  11 → 15 (army selection + fight summary)
  13 → 16 (victory screen)
  12, 13, 16 → 17 (wire victory check)
  08, 09 → 18 (upgrade section kernel requirement)

Phase 6: Integration
  01-18 → 19 (integration test)
```

## Execution Order

Tasks within the same phase can be executed in parallel where their dependencies allow.

| Order | Tasks | Can Parallelize |
|-------|-------|-----------------|
| 1     | 01, 02, 03 | Yes (independent Hive changes) |
| 2     | 04 | No (depends on 01-03) |
| 3     | 05, 06, 07, 09, 10 | Yes (all depend on 04 only) |
| 4     | 08 | No (depends on 07) |
| 5     | 11, 12, 13 | Yes (independent domain logic) |
| 6     | 14, 15, 16, 18 | Yes (independent UI work) |
| 7     | 17 | No (depends on 12, 13, 16) |
| 8     | 19 | No (depends on all) |

## Critical Path

01/02/03 → 04 → 07 → 08 → 18
01/02/03 → 04 → 06 → 11 → 15
01/02/03 → 04 → 09 → 11 → 14
02/03 → 12 → 17
13 → 16 → 17
All → 19
