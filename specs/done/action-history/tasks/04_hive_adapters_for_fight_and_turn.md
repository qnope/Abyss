# Task 04 — Hive Adapters for Fight and Turn Types

## Summary

Add Hive annotations / adapters for the types that `CombatEntry` and `TurnEndEntry` embed but that currently have no adapter: `FightResult`, `FightTurnSummary`, `Combatant`, `CombatSide`, and `TurnResourceChange`. Also write the generated `.g.dart` files for the new history entry classes from tasks 01–03.

## Implementation Steps

1. **CombatSide** (`lib/domain/fight/combat_side.dart`):
   - Add `@HiveType(typeId: 26)` and `@HiveField(n)` per enum value.
2. **Combatant** (`lib/domain/fight/combatant.dart`):
   - Add `@HiveType(typeId: 27)` and `@HiveField(n)` on `side`, `typeKey`, `maxHp`, `atk`, `def`, `currentHp`.
   - Constructor must allow Hive to rebuild the object with all fields (add named parameters if needed).
3. **FightTurnSummary** (`lib/domain/fight/fight_turn_summary.dart`):
   - Add `@HiveType(typeId: 28)` and `@HiveField` on all fields.
4. **FightResult** (`lib/domain/fight/fight_result.dart`):
   - Add `@HiveType(typeId: 29)` and annotate every field (`winner`, `turnCount`, `turnSummaries`, `initialPlayerCombatants`, `finalPlayerCombatants`, `initialMonsterCount`, `finalMonsterCount`).
5. **TurnResourceChange** (`lib/domain/turn/turn_result.dart`):
   - Add `@HiveType(typeId: 30)` and annotate every field. The outer `TurnResult` stays un-annotated (it's runtime-only).
6. Run `dart run build_runner build --delete-conflicting-outputs` to regenerate every `.g.dart` file touched (including the new history entry files from tasks 01–03).
7. Register all new adapters in `GameRepository.initialize()`:
   - `HistoryEntryCategoryAdapter`
   - `BuildingEntryAdapter`, `ResearchEntryAdapter`, `RecruitEntryAdapter`, `ExploreEntryAdapter`, `CollectEntryAdapter`
   - `CombatEntryAdapter`, `TurnEndEntryAdapter`
   - `CombatSideAdapter`, `CombatantAdapter`, `FightTurnSummaryAdapter`, `FightResultAdapter`
   - `TurnResourceChangeAdapter`

## Dependencies

- Blocks: task 05 (Player field), task 07 (action wiring), task 10 (persistence tests).
- Blocked by: tasks 01, 02, 03.

## Test Plan

- `test/data/history_adapters_test.dart`:
  - Open a temporary in-memory Hive box, round-trip each entry type (BuildingEntry, ResearchEntry, RecruitEntry, ExploreEntry, CollectEntry, CombatEntry, TurnEndEntry) and assert deep equality of scalar fields, title, category, and embedded maps.
  - Specifically for `CombatEntry`: round-trip a `FightResult` with one `FightTurnSummary` and two `Combatant` entries on each side. Verify turn summaries survive.
- `test/domain/fight/fight_result_hive_test.dart`:
  - Quick adapter sanity check for `FightResult` alone (no history context).

## Notes

- Pick `typeId` values 18–30 in the order given above. Update the typeId comment table in the architecture README when updating the domain doc later (task 14).
- Constructors touched in this task must remain compatible with existing call sites — prefer adding Hive annotations on existing positional/named parameters rather than changing shapes.
- Each file must stay under 150 lines; if `fight_result.dart` grows over, split helpers out.
