# Dependency Graph — game-player-decoupling

## Execution Order

```
Phase 1 — Foundation (mostly parallelizable):
  01_add_uuid_dependency
  02_extend_player_model              ← depends on 01
  03_update_mapcell_collected_by
  04_update_gamemap_remove_base_coords
  05_refactor_game_container          ← depends on 02

Phase 2 — Action contract (sequential by nature):
  06_update_action_contract           ← depends on 02, 05
  07_migrate_collect_treasure_action  ← depends on 02, 03, 06
  08_migrate_explore_action           ← depends on 02, 06
  09_migrate_upgrade_building_action  ← depends on 02, 06
  10_migrate_recruit_unit_action      ← depends on 02, 06
  11_migrate_tech_actions             ← depends on 02, 06

Phase 3 — Map + resolvers:
  12_update_map_generator             ← depends on 04
  13_update_exploration_resolver      ← depends on 02, 03, 05
  14_update_turn_resolver             ← depends on 02, 05, 13

Phase 4 — Persistence:
  15_regenerate_hive_adapters         ← depends on 02, 03, 04, 05

Phase 5 — Presentation wiring:
  16_update_new_game_bootstrap        ← depends on 02, 05, 12, 15
  17_update_game_screen_and_helpers   ← depends on 06, 07, 08, 09, 10, 11, 16
  18_update_map_widgets               ← depends on 02, 03, 04, 17

Phase 6 — Tests:
  19_domain_tests_model               ← depends on 02, 03, 04, 05, 12
  20_action_tests_migration           ← depends on 07, 08, 09, 10, 11
  21_resolver_tests_migration         ← depends on 13, 14
  22_presentation_tests_migration     ← depends on 15, 16, 17, 18

Phase 7 — Final validation:
  23_run_analyze_and_test             ← depends on 19, 20, 21, 22
  24_update_architecture_docs         ← depends on 23
```

## Dependency Matrix

| Task | Depends on |
|------|-----------|
| 01 | — |
| 02 | 01 |
| 03 | — |
| 04 | — |
| 05 | 02 |
| 06 | 02, 05 |
| 07 | 02, 03, 06 |
| 08 | 02, 06 |
| 09 | 02, 06 |
| 10 | 02, 06 |
| 11 | 02, 06 |
| 12 | 04 |
| 13 | 02, 03, 05 |
| 14 | 02, 05, 13 |
| 15 | 02, 03, 04, 05 |
| 16 | 02, 05, 12, 15 |
| 17 | 06, 07, 08, 09, 10, 11, 16 |
| 18 | 02, 03, 04, 17 |
| 19 | 02, 03, 04, 05, 12 |
| 20 | 07, 08, 09, 10, 11 |
| 21 | 13, 14 |
| 22 | 15, 16, 17, 18 |
| 23 | 19, 20, 21, 22 |
| 24 | 23 |

## Parallelization Notes

- **Within Phase 1**: tasks 01, 03, 04 are fully independent; 02 waits on 01; 05 waits on 02. An efficient run order is `01 → {02, 03, 04 in parallel} → 05`.
- **Within Phase 2 (action migrations)**: after 06, tasks 07–11 are independent of each other and can run in parallel; they only share the `Action` contract.
- **Phase 3 + Phase 4**: `12` and `13` can run in parallel; `14` waits on `13`; `15` can run in parallel with `12`/`13`/`14` as long as they don't race on `build_runner` output (run `15` last in this cluster to be safe).
- **Phase 6 (tests)**: `19`, `20`, `21`, `22` are independent and can be written in parallel by separate agents.
- **Phase 7**: strictly sequential (`23 → 24`).

## Files Created

| Task | New Files |
|------|-----------|
| 01 | — (edits `pubspec.yaml`) |
| 02 | — (edits `player.dart`; possibly creates `player_defaults.dart` if length rule forces a split) |
| 03 | — (edits `map_cell.dart`) |
| 04 | — (edits `game_map.dart`) |
| 05 | — (edits `game.dart`) |
| 06 | — (edits `action.dart`, `action_executor.dart`) |
| 07 | — (edits `collect_treasure_action.dart`) |
| 08 | — (edits `explore_action.dart`) |
| 09 | — (edits `upgrade_building_action.dart`) |
| 10 | — (edits `recruit_unit_action.dart`) |
| 11 | — (edits `research_tech_action.dart`, `unlock_branch_action.dart`) |
| 12 | `lib/domain/map/map_generation_result.dart` (optional — may inline a record instead) |
| 13 | — (edits `exploration_resolver.dart`) |
| 14 | — (edits `turn_resolver.dart`; possibly `player_turn_resolver.dart` if length rule forces a split) |
| 15 | — (regenerates `.g.dart`; may touch top-level `README.md`) |
| 16 | — (edits `new_game_screen.dart`, `game_screen_map_actions.dart`) |
| 17 | — (edits `game_screen.dart`, `game_screen_actions.dart`, `game_screen_map_actions.dart`, `game_screen_tech_actions.dart`, `game_screen_turn_helpers.dart`) |
| 18 | — (edits `map_cell_widget.dart`, `game_map_view.dart`) |
| 19 | `test/domain/game/player_test.dart`, `test/domain/map/game_map_test.dart`, `test/domain/map/map_generator_test.dart` (if missing) |
| 20 | — (edits existing `test/domain/action/*_test.dart` + helper) |
| 21 | — (edits `test/domain/map/exploration_resolver_test.dart`, `test/domain/turn/turn_resolver_test.dart`) |
| 22 | `test/data/game_repository_roundtrip_test.dart`, `test/presentation/widgets/map/game_map_view_test.dart` (if missing) |
| 23 | — |
| 24 | `specs/architecture/domain/game/README.md`, `specs/architecture/domain/map/README.md`, `specs/architecture/domain/action/README.md` (if any are missing) |

## Files Modified

- `pubspec.yaml`, `pubspec.lock` (task 01)
- `lib/domain/game/player.dart`, `lib/domain/game/player.g.dart` (tasks 02, 15)
- `lib/domain/game/game.dart`, `lib/domain/game/game.g.dart` (tasks 05, 15)
- `lib/domain/map/map_cell.dart`, `lib/domain/map/map_cell.g.dart` (tasks 03, 15)
- `lib/domain/map/game_map.dart`, `lib/domain/map/game_map.g.dart` (tasks 04, 15)
- `lib/domain/map/map_generator.dart` (task 12)
- `lib/domain/map/exploration_resolver.dart` (task 13)
- `lib/domain/turn/turn_resolver.dart` (task 14)
- `lib/domain/action/action.dart`, `action_executor.dart` (task 06)
- `lib/domain/action/collect_treasure_action.dart` (task 07)
- `lib/domain/action/explore_action.dart` (task 08)
- `lib/domain/action/upgrade_building_action.dart` (task 09)
- `lib/domain/action/recruit_unit_action.dart` (task 10)
- `lib/domain/action/research_tech_action.dart`, `unlock_branch_action.dart` (task 11)
- `lib/data/game_repository.dart` (task 15 — verification only)
- `lib/presentation/screens/menu/new_game_screen.dart` (task 16)
- `lib/presentation/screens/game/game_screen.dart` + sibling helpers (task 17)
- `lib/presentation/widgets/map/map_cell_widget.dart`, `game_map_view.dart` (task 18)
- Test files across `test/domain/`, `test/data/`, `test/presentation/` (tasks 19–22)
- `specs/architecture/**/README.md` (task 24)
- Top-level `README.md` (task 15)
