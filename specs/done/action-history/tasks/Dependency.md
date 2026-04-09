# Task Dependencies

Visual dependency graph for the **action-history** project. Each arrow means "must be completed before".

```
01 (base model)
 ├── 02 (simple entries)
 │    └── 03 (combat + turn-end entries)
 │         └── 04 (Hive adapters for fight/turn)
 │              └── 05 (Player.historyEntries field)
 │                   └── 06 (Action.makeHistoryEntry API)
 │                        └── 07 (ActionExecutor wiring)
 │                             └── 08 (EndTurnAction)
 │                                  └── 11 (integration tests + docs in task 14)
 ├── 09 (presentation extensions)
 │    └── 10 (HistoryEntryCard widget)
 │         └── 12 (HistorySheet modal)
 ├── 11 (HistoryFilter logic + chips)
 │    └── 12 (HistorySheet modal)
 └── 12 (HistorySheet modal)
      └── 13 (Settings dialog integration)
           └── 14 (Integration tests + docs)
```

## Per-task dependencies

| Task | Depends on | Blocks |
|---|---|---|
| 01 Base model | — | 02, 03, 09 |
| 02 Simple entries | 01 | 03, 04 |
| 03 Combat + turn-end entries | 01, 02 | 04, 06, 08 |
| 04 Hive adapters | 01, 02, 03 | 05, 10 (indirectly via 07) |
| 05 Player.historyEntries | 04 | 06, 07 |
| 06 Action.makeHistoryEntry | 01, 02, 03, 05 | 07 |
| 07 ActionExecutor wiring | 05, 06 | 08, 14 |
| 08 EndTurnAction | 03, 05, 06, 07 | 14 |
| 09 Presentation extensions | 01, 02, 03 | 10 |
| 10 HistoryEntryCard widget | 01–03, 09 | 12 |
| 11 HistoryFilter logic | 01–03 | 12 |
| 12 HistorySheet modal | 05, 09, 10, 11 | 13 |
| 13 Settings dialog integration | 12 | 14 |
| 14 Integration tests + docs | 07, 08, 13 | — |

## Critical path

**01 → 02 → 03 → 04 → 05 → 06 → 07 → 08 → 14**

The presentation track (09 → 10 → 11 → 12 → 13) can run in parallel once task 03 is complete, converging at task 14 which exercises both the domain and presentation work end-to-end.

## External dependencies

- `package:hive` / `package:hive_flutter` — already in `pubspec.yaml`. No new dependencies introduced.
- `package:build_runner`, `package:hive_generator` — already used, required for `.g.dart` regeneration (tasks 04 and 05 in particular).
- `flutter_test` / `hive_test` (if absent, fall back to a temporary directory for Hive) — used in task 04 and task 14 persistence tests.
