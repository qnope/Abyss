# History Module

## Overview

The history module records a compact, persistent log of every
meaningful player action and end-of-turn resolution. Each `Player`
carries its own `List<HistoryEntry>` (FIFO capped at **100** entries,
oldest first in storage) that is written by `ActionExecutor` whenever
an `Action` completes successfully.

The log is **write-only from the domain side**: actions never read
from it, and nothing outside the presentation layer branches on its
contents. The module is therefore effectively a sink.

## The sealed `HistoryEntry` hierarchy

`HistoryEntry` is a sealed abstract class declared in
`lib/domain/history/history_entry.dart`. Being sealed lets the
presentation layer use exhaustive `switch` statements on concrete
types. Every concrete subclass lives in a `part` file under `entries/`
(sealed classes must share a library) and carries its own `@HiveType`
annotation — Hive does not walk abstract bases.

Common contract (`HistoryEntry`):

- `int get turn` — the turn on which the event occurred.
- `HistoryEntryCategory get category` — enum used by filters and
  icons.
- `String get title` — short, French, human-readable label.
- `String? get subtitle` — optional extra line.

## Concrete subclasses

| Class | typeId | Category | Added by |
|---|---|---|---|
| `BuildingEntry` | 19 | `building` | `UpgradeBuildingAction` |
| `ResearchEntry` | 20 | `research` | `UnlockBranchAction`, `ResearchTechAction` |
| `RecruitEntry` | 21 | `recruit` | `RecruitUnitAction` |
| `ExploreEntry` | 22 | `explore` | `ExploreAction` |
| `CollectEntry` | 23 | `collect` | `CollectTreasureAction` |
| `CombatEntry` | 24 | `combat` | `FightMonsterAction` |
| `TurnEndEntry` | 25 | `turnEnd` | `EndTurnAction` |

Supporting Hive types: `HistoryEntryCategory` (typeId 18),
`TurnResourceChange` (typeId 26) stored inside `TurnEndEntry`, and the
combat types reused from the `fight` submodule (`FightResult`,
`FightTurnSummary`, `Combatant`, `CombatSide`).

`CombatEntry` is the only entry that is **tappable** in the
presentation layer: it embeds a full `FightResult` so the existing
`FightSummaryScreen` can be rebuilt from the log without any extra
domain plumbing.

## FIFO invariant

`Player.addHistoryEntry` is the single insertion point:

```dart
void addHistoryEntry(HistoryEntry entry) {
  historyEntries.add(entry);
  while (historyEntries.length > kHistoryMaxEntries) {
    historyEntries.removeAt(0);
  }
}
```

The constant `kHistoryMaxEntries = 100` lives in
`history_constants.dart`. The invariant guarantees:

- the list never exceeds 100 entries;
- entries are stored oldest-first, so the presentation layer reverses
  them when rendering newest-first;
- dropping from the head is `O(n)` once the cap is reached, which is
  acceptable at the scale of a turn-based game.

## `Action.makeHistoryEntry` and the executor hook

The base `Action` class exposes:

```dart
HistoryEntry? makeHistoryEntry(
  Game game,
  Player player,
  ActionResult result,
  int turn,
) => null;
```

Concrete actions override it to build the matching entry. The default
implementation returns `null`, which is useful for test doubles and
future actions that should not be logged.

`ActionExecutor` is the only caller:

```dart
ActionResult execute(Action action, Game game, Player player) {
  final validation = action.validate(game, player);
  if (!validation.isSuccess) return validation;
  final result = action.execute(game, player);
  if (result.isSuccess) {
    final entry = action.makeHistoryEntry(game, player, result, game.turn);
    if (entry != null) player.addHistoryEntry(entry);
  }
  return result;
}
```

Consequences:

- Validation failures are **never** logged.
- Execute failures are **never** logged (result must be successful).
- Each action decides its own `turn` argument policy. For example,
  `EndTurnAction` uses `tr.previousTurn` so the entry reflects the
  turn that just ended, not the newly-advanced one.

## File map

| File | Role |
|---|---|
| `history_entry.dart` | Sealed `HistoryEntry` base + `part` directives |
| `history_entry_category.dart` | `HistoryEntryCategory` enum |
| `history_constants.dart` | `kHistoryMaxEntries` |
| `entries/building_entry.dart` | `BuildingEntry` |
| `entries/research_entry.dart` | `ResearchEntry` |
| `entries/recruit_entry.dart` | `RecruitEntry` |
| `entries/explore_entry.dart` | `ExploreEntry` |
| `entries/collect_entry.dart` | `CollectEntry` |
| `entries/combat_entry.dart` | `CombatEntry` (carries `FightResult`) |
| `entries/turn_end_entry.dart` | `TurnEndEntry` |
| `entries/turn_end_entry_factory.dart` | Builds `TurnEndEntry` from a `TurnResult` |
