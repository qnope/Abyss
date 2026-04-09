# Task 03 — Combat and Turn-End History Entries

## Summary

Implement the two "rich" history entry subclasses: `CombatEntry` (carries the full `FightMonsterResult` replay data) and `TurnEndEntry` (carries the per-turn production recap + deactivated buildings + lost units). These require additional Hive adapters on fight and turn types.

## Implementation Steps

### CombatEntry

Create `lib/domain/history/entries/combat_entry.dart`:

- `@HiveType(typeId: 24)`.
- Extends `HistoryEntry` with `category = HistoryEntryCategory.combat`.
- Title example: `Victoire vs Tanière niv 2` or `Défaite vs Tanière niv 3`.
- Extra fields (`@HiveField(4..)`):
  - `bool victory`
  - `int targetX`, `int targetY`
  - `MonsterLair lair` (already Hive-serializable, typeId 17)
  - `FightResult fightResult` (new adapter — see below)
  - `Map<ResourceType, int> loot`
  - `Map<UnitType, int> sent`
  - `Map<UnitType, int> survivorsIntact`
  - `Map<UnitType, int> wounded`
  - `Map<UnitType, int> dead`

### TurnEndEntry

Create `lib/domain/history/entries/turn_end_entry.dart`:

- `@HiveType(typeId: 25)`.
- Extends `HistoryEntry` with `category = HistoryEntryCategory.turnEnd`.
- Title: `Tour N terminé` (where N = turn number recorded).
- Extra fields:
  - `List<TurnResourceChange> changes` (reuses existing class — needs Hive adapter, see task 04)
  - `List<BuildingType> deactivatedBuildings`
  - `Map<UnitType, int> lostUnits`

### Helper

Create `lib/domain/history/entries/turn_end_entry_factory.dart`:

- Pure function `TurnEndEntry fromTurnResult(TurnResult result)`.
- Extracts the relevant fields from a `TurnResult` into a `TurnEndEntry`.
- Keeps factory logic separate so `TurnEndEntry` stays a dumb data class.

## Dependencies

- Blocks: task 04 (adapter registration), task 07 (action-level wiring).
- Blocked by: task 01 (base class), task 02 (pattern reference).
- Depends on existing types: `FightResult`, `FightTurnSummary`, `Combatant`, `MonsterLair`, `TurnResourceChange`, `BuildingType`, `UnitType`, `ResourceType`.

## Test Plan

- `test/domain/history/entries/combat_entry_test.dart`:
  - Build a `CombatEntry` manually with a faked `FightResult` containing one `FightTurnSummary` and verify all fields round-trip to getters.
  - Verify title switches on `victory`.
- `test/domain/history/entries/turn_end_entry_test.dart`:
  - Construct from a `TurnResult` via the factory; assert fields.

## Notes

- Do not yet wire these into actions — that's task 07 / 09.
- Hive adapter generation for new fields happens in task 04.
- Each file stays under 150 lines.
