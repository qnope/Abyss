# Dependencies — improve-fight

## Per-task dependencies

| Task | Title                                          | Depends on    | Blocks         |
|------|------------------------------------------------|---------------|----------------|
| 01   | CombatantBuilder military bonus                | —             | 02, 07         |
| 02   | FightMonsterAction forwards military level     | 01            | 03, 06, 07     |
| 03   | Restore intact survivors                       | 02 (helper)   | 07             |
| 04   | UnitQuantityRow slider                         | —             | 06             |
| 05   | SelectionSummaryCard widget                    | —             | 06             |
| 06   | ArmySelectionScreen integration                | 02, 04, 05    | 07, 09         |
| 07   | Integration test: military tech                | 01, 02, 03    | 09             |
| 08   | Update architecture docs                       | 01-06         | 09             |
| 09   | Quality gates (analyze + test + line budget)   | 01-08         | finalize       |

## Suggested execution order

```
01 ─┬─ 02 ─┬─ 03 ──┐
    │      └────────┐
    │               │
04 ─┘               │
05 ──── 06 ─────────┤
                    │
                    07
                    │
                    08
                    │
                    09
```

Tasks **01**, **04**, and **05** are leaf nodes and can be picked up
in parallel by different developers if needed. **02** unblocks the
deepest chain (the action + integration test path), so prioritize it
right after 01.

## External / cross-cutting dependencies

- **Hive**: no schema change. `TechBranchState` already stores
  `researchLevel`; we only read it.
- **Flutter Material**: `Slider` and `Card` are pre-imported via
  `material.dart`.
- **CLAUDE.md rules**:
  - 150-line ceiling per file → enforced in task 09 and re-checked at
    each touched file.
  - 5-layer architecture → bonus math lives in `domain/fight/`,
    UI label and totals live in `presentation/`.
  - No `initialize()` methods → all new widgets are stateless or use
    constructors only.

## Test files affected (regression watch list)

These files exist today and must keep passing after the project's
changes:

- `test/domain/fight/combatant_builder_test.dart` (extended in 01)
- `test/domain/action/fight_monster_action_casualty_test.dart`
  (extended in 03)
- `test/domain/action/fight_monster_action_validate_test.dart`
- `test/domain/action/fight_monster_action_victory_test.dart`
- `test/domain/action/fight_monster_action_defeat_test.dart`
- `test/domain/action/fight_monster_action_integration_test.dart`
- `test/data/game_repository_fight_persistence_test.dart`
- `test/presentation/screens/game/fight/army_selection_screen_test.dart`
  (extended in 06)
- `test/presentation/widgets/fight/unit_quantity_row_test.dart`
  (extended in 04)

Task 09's `flutter test` run is the gate that proves no regression.
