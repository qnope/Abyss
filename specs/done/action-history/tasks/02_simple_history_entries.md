# Task 02 — Simple History Entry Subclasses

## Summary

Implement the simple (non-combat, non-turn-end) concrete `HistoryEntry` subclasses used by most player actions: building, research, recruitment, exploration, collect. Each is Hive-serializable so persistence works out of the box.

## Implementation Steps

Create one file per entry subclass under `lib/domain/history/entries/`. Each extends `HistoryEntry` and carries type-safe domain data in addition to base fields.

| File | Class | Extra fields |
|---|---|---|
| `building_entry.dart` | `BuildingEntry` (typeId 19) | `BuildingType buildingType`, `int newLevel` |
| `research_entry.dart` | `ResearchEntry` (typeId 20) | `TechBranch branch`, `bool isUnlock` (true for `unlockBranch`, false for `researchTech`), `int? newLevel` |
| `recruit_entry.dart` | `RecruitEntry` (typeId 21) | `UnitType unitType`, `int quantity` |
| `explore_entry.dart` | `ExploreEntry` (typeId 22) | `int targetX`, `int targetY` |
| `collect_entry.dart` | `CollectEntry` (typeId 23) | `int targetX`, `int targetY`, `Map<ResourceType, int> gains` |

For each subclass:
- `@HiveType(typeId: N)` declaration.
- `@HiveField(0..3)` for base fields (turn, category, title, subtitle) — repeated on the concrete class because Hive does not walk abstract bases.
- `@HiveField(4+)` for extra fields.
- Pass the correct `HistoryEntryCategory` to the super constructor and set a human-readable French `title` (e.g. `Caserne niv 3`, `Métallurgie débloquée`, `10 gardes recrutés`, `Exploration (5, 7)`, `Trésor collecté (2, 4)`).

## Dependencies

- Blocks: task 03 (combat/turn-end entries), task 04 (Hive adapter registration).
- Blocked by: task 01 (base class).
- Internal: `BuildingType`, `TechBranch`, `UnitType`, `ResourceType`.

## Test Plan

- `test/domain/history/entries/building_entry_test.dart`:
  - Construct a `BuildingEntry(turn: 3, buildingType: BuildingType.barracks, newLevel: 2)` and assert category, title, fields.
- `test/domain/history/entries/research_entry_test.dart`:
  - Construct both unlock and research variants; verify title text differs.
- `test/domain/history/entries/recruit_entry_test.dart`:
  - Verify `quantity` appears in title/subtitle.
- `test/domain/history/entries/explore_entry_test.dart`:
  - Verify coords in title.
- `test/domain/history/entries/collect_entry_test.dart`:
  - Verify gains map round-trips.

## Notes

- Each file stays under 150 lines.
- Keep titles in French (game locale).
- No Hive box operations in these tests — pure domain.
