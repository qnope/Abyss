# Display Map — Task Dependencies

## Dependency Graph

```
01_domain_enums
├──▶ 02_map_cell_model
│    └──▶ 03_game_map_grid_position
│         └──▶ 04_game_field_build_runner
│              └──▶ 05_register_hive_adapters
│
├──▶ 06_terrain_generator  (also needs 02)
├──▶ 07_content_placer     (also needs 02)
│
06 + 07 ──▶ 08_map_generator (also needs 03)
│
01 ──▶ 09_map_extensions
│
02 + 09 ──▶ 10_map_cell_widget
│
03 + 10 ──▶ 11_game_map_view
│
05 + 08 + 11 ──▶ 12_game_screen_integration
│
All (1–12) ──▶ 13_integration_tests
│
All (1–13) ──▶ 14_final_validation
```

## Parallelization Opportunities

| Phase | Tasks (can run in parallel) |
|-------|----------------------------|
| 1 | 01 |
| 2 | 02, 09 (both depend only on 01) |
| 3 | 03, 06, 07 (03 needs 02; 06/07 need 01+02) |
| 4 | 04, 08, 10 (04 needs 03; 08 needs 06+07+03; 10 needs 02+09) |
| 5 | 05, 11 (05 needs 04; 11 needs 03+10) |
| 6 | 12 (needs 05+08+11) |
| 7 | 13 (needs all) |
| 8 | 14 (needs all) |

## Critical Path

`01 → 02 → 03 → 04 → 05 → 12 → 13 → 14`

The domain model chain (Tasks 1–5) is the bottleneck since `build_runner` must run before any presentation work can be fully validated.

## External Dependencies

- **flutter_svg** (already in pubspec.yaml) — used by Tasks 10, 11
- **hive / hive_generator / build_runner** (already in pubspec.yaml) — used by Task 4
- **SVG assets** (`assets/icons/terrain/`, `assets/icons/map_content/`) — already present
- **AbyssColors** (terrain colors already defined) — used by Tasks 9, 10, 11
