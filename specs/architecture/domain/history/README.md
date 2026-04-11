# History Module

The history module records a compact, persistent log of every meaningful
player action and end-of-turn resolution. Each `Player` carries its own
`List<HistoryEntry>` (FIFO capped at **100** entries, oldest first in
storage) that is written by `ActionExecutor` whenever an `Action`
completes successfully.

The log is **write-only from the domain side**: actions never read from
it, and nothing outside the presentation layer branches on its contents.
The module is therefore effectively a sink.

## The sealed `HistoryEntry` hierarchy

`HistoryEntry` is a sealed abstract class declared in
`lib/domain/history/history_entry.dart`. Being sealed lets the
presentation layer use exhaustive `switch` statements on concrete types.
Every concrete subclass lives in a `part` file under `entries/` (sealed
classes must share a library) and carries its own `@HiveType` annotation
— Hive does not walk abstract bases.

Common contract:

- `int get turn` — the turn on which the event occurred.
- `HistoryEntryCategory get category` — enum used by filters and icons.
- `String get title` — short, French, human-readable label.
- `String? get subtitle` — optional extra line.

### Concrete subclasses

| Class | Category | Added by |
|---|---|---|
| `BuildingEntry` | `building` | `UpgradeBuildingAction` |
| `ResearchEntry` | `research` | `UnlockBranchAction`, `ResearchTechAction` |
| `RecruitEntry` | `recruit` | `RecruitUnitAction` |
| `ExploreEntry` | `explore` | `ExploreAction` |
| `CollectEntry` | `collect` | `CollectTreasureAction` |
| `CombatEntry` | `combat` | `FightMonsterAction` |
| `CaptureEntry` | `capture` | `AttackTransitionBaseAction` |
| `DescentEntry` | `descent` | `DescendAction` |
| `ReinforcementEntry` | `reinforcement` | `SendReinforcementsAction` |
| `TurnEndEntry` | `turnEnd` | `EndTurnAction` |

`CombatEntry` is the only entry that is **tappable** in the presentation
layer: it embeds a full `FightResult` so the existing `FightSummaryScreen`
can be rebuilt from the log without any extra domain plumbing.
`TurnEndEntry` embeds a list of `TurnResourceChange` summarising the
per-resource production delta of the resolved turn.

## FIFO invariant

`Player.addHistoryEntry` is the single insertion point. The constant
`kHistoryMaxEntries = 100` lives in `history_constants.dart`. The
invariant guarantees:

- the list never exceeds 100 entries;
- entries are stored oldest-first, so the presentation layer reverses
  them when rendering newest-first;
- dropping from the head is `O(n)` once the cap is reached, which is
  acceptable at the scale of a turn-based game.

## `Action.makeHistoryEntry` and the executor hook

The base `Action` class exposes an overridable hook:

```dart
HistoryEntry? makeHistoryEntry(
  Game game,
  Player player,
  ActionResult result,
  int turn,
) => null;
```

`ActionExecutor` is the only caller. After a successful `execute`, it
calls `makeHistoryEntry(game, player, result, game.turn)` and appends
the non-null result to the player via `addHistoryEntry`.

Consequences:

- Validation failures are **never** logged.
- Execute failures are **never** logged.
- Each action decides its own `turn` argument policy. For example,
  `EndTurnAction` uses `tr.previousTurn` so the entry reflects the turn
  that just ended, not the newly-advanced one.

## Dependency flow

```
history --> building, tech, unit, resource, map, fight, turn
```

Nothing imports `history` back. Concrete entries are models built from
the domain types they describe; the executor hook lives on `Action`, so
the `action` submodule is the only one that materialises entries.
