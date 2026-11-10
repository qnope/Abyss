# Reference games

The rules of ABYSSES are being ported from Dart (`lib/domain`) to GDScript
(`godot/domain`), and the port must play **exactly the same game**. The proof
is here: games played by the Flutter rules, each with the journal of its
moves and, turn after turn, a digest of every part of its state. The Godot
port replays the journal and must find the same digests.

This file specifies the format, so that GDScript writes the very same bytes.
The Dart side lives in `lib/domain/reference/`.

## Canonical text

A value of the state is written as a strict subset of JSON
(`CanonicalWriter`). Only six kinds of values exist: **null**, **booleans**,
**integers**, **strings**, **lists** and **maps** whose keys are strings.

- No whitespace anywhere: `{"a":[1,2],"b":null}`.
- `null`, `true`, `false` as in JSON.
- An integer in decimal, with `-` when negative, no leading zero, no
  exponent, no fraction: `0`, `-42`, `2083200441`.
- A **double is never written as a number**, so no float formatting can
  differ between two languages. It is the *string* `d:` followed by the 16
  lowercase hexadecimal digits of its IEEE-754 binary64 bits, most
  significant first: `1.0` is `"d:3ff0000000000000"`, `-0.0` is
  `"d:8000000000000000"` (the sign of zero is kept), `+∞` is
  `"d:7ff0000000000000"`. **NaN is refused** (it has many bit patterns): the
  writer throws. The state of a game holds no double today; the rule is there
  for the day it does.
- A string is between `"`, with exactly three escapes: `"` is `\"`, `\` is
  `\\`, and a character below U+0020 is `\u00xx` with two lowercase
  hexadecimal digits (a line feed is `\u000a`, never `\n`). Everything else
  is written raw: `/`, U+007F, accents, emoji. The text is then encoded in
  UTF-8.
- A list is `[a,b,c]`, in its own order.
- A map is `{"key":value,...}` with its keys **sorted by UTF-16 code unit**
  (what Dart's `String.compareTo` does; in GDScript, compare the strings
  code unit by code unit, the shorter first when one starts the other). All
  the keys written today are ASCII names, where any byte order agrees.

Anything else (an enum, a date, a set, a map with other keys) is refused by
the writer: a snapshot turns it into one of the six kinds first.

The text of a list or a map is the concatenation of the texts of its items,
so an implementation may keep the text of an object that no longer changes
(a history entry) instead of writing it again every turn.

## Digest

The digest of a section is the **SHA-256** of the UTF-8 bytes of its
canonical text, in lowercase hexadecimal (64 characters). The domain only
produces the texts: `GameSnapshot.digests` is given the digest function.

## From the model to values

The state of a game is what a save holds: the `@HiveType` classes and their
`@HiveField` fields, starting from `Game`. A snapshot (`GameSnapshot`) only
reads the game.

- **An object** of a persisted class is a map with one entry per field, under
  the name of the Dart field (the list is below). A missing object is `null`.
- **An enum** value is its Dart name: `"algaeFarm"`, `"victory"`.
- **A Dart `List`** is a list, in its order: the order of a list is state.
- **A Dart `Map`** is **a list of `[key, value]` pairs, in the order the map
  iterates** (its insertion order), *not* a canonical map. That order is
  state: a fight lines the units up in the order of the map that holds them,
  and a canonical map would lose it by sorting its keys. Enum keys are their
  names, integer keys (levels, turns) stay integers. A GDScript `Dictionary`
  iterates in insertion order too, so the port must fill its dictionaries in
  the same order as the Dart code.
- No `Set` and no map with an order that changes from one run to the next is
  persisted, so nothing needs sorting besides the keys of the canonical maps.
- **Player ids.** The id of the human is drawn at random when a game starts
  (a UUID). Wherever a player id is written (the key of a player, the owner
  of a cell or of a post, the sender of an attack, the keys of the scouts'
  reports and of the attack cool-downs), the human's id is written `human`.
  A faction keeps its id, `faction-` followed by its personality
  (`faction-pearlOrder`), which is the same in every game.
- **No date.** `Game.createdAt` and `Game.savedLastPlayedAt` are wall-clock
  values and are left out; no rule reads them.
- **Nothing derived is persisted**, so nothing is left out as derived. What a
  save does not hold (computed getters, the `role` and `family` of a
  `Combatant`, the caches of the fight rehearsals) is recomputed from the
  state and is not written.

Fields written under another key than their Dart name, which only tells how
old saves stored them: `Game.savedDifficulty` is `difficulty` (the value in
force, `normal` when the field is missing), `Game.savedFactions` is `factions`
(empty when missing), `Player.savedFallen` is `fallen` (`false` when missing),
`Player.savedIntel` is `intel` (empty when missing), and
`Player.savedObjectiveState` is `objectiveState`.

The journal (`ReplayJournal.actions`) holds each action as a JSON string. The
snapshot decodes it and writes every JSON object as the list of its
`[key, value]` pairs **in the order the journal wrote them** (`do` first, the
units in the order they were sent, `player` last), so the layout of that JSON
is not part of the state but the order of the units is.

`TechBranchState.choices` is the list of option indexes (0 for option A, 1
for B), as saved.

### Sections

A snapshot is split in 20 sections (`SnapshotSections`), so that two games
that differ tell where. Their names, sorted, give the order of the digests.

| Section | Holds | Shape |
|---|---|---|
| `game` | `Game`: `difficulty`, `factions`, `humanPlayerId` (always `human`), `status`, `turn` | map |
| `journal` | `Game.replay` | `{"replay": ReplayJournal or null}` |
| `leviathan` | `Game.leviathanReturn` | `{"leviathanReturn": LeviathanReturn or null}` |
| `map1`, `map2`, `map3` | `Game.levels[1]`, `[2]`, `[3]` | `GameMap`, or `null` while the level is not generated |
| `players` | `Player`: `name`, `id`, `baseX`, `baseY`, `fallen` | per player |
| `resources` | `Player.resources` | per player |
| `buildings` | `Player.buildings` | per player |
| `worksite` | `Player.worksite` | per player |
| `tech` | `Player.techBranches` | per player |
| `units` | `Player.unitsPerLevel`, `recruitedUnitTypes` | per player |
| `orders` | `Player.pendingExplorations`, `pendingReinforcements` | per player |
| `fog` | `Player.revealedCellsPerLevel` | per player |
| `raids` | `Player.raidState` | per player |
| `volcano` | `Player.volcanoState` | per player |
| `events` | `Player.eventState` | per player |
| `objectives` | `Player.objectiveState` | per player |
| `intel` | `Player.intel` | per player |
| `history` | `Player.historyEntries` | per player |

A section *per player* is the list of the pairs `[player id, {fields}]` for
every player of `Game.players`, in its order (the human first, then the
factions in the order they play): the fields are the ones the table names.
For instance, at the start of a game against one faction:

```
worksite  [["human",{"worksite":{"research":0,"upgrades":0}}],["faction-pearlOrder",{"worksite":{"research":0,"upgrades":0}}]]
game      {"difficulty":"normal","factions":["pearlOrder"],"humanPlayerId":"human","status":"playing","turn":1}
```

A game without faction generates its levels 2 and 3 when the player first
goes down; a game against factions has the three from the start. A level
outside 1 to 3 makes the snapshot fail.

### Keys of each class

A history entry is told from the others by its `category`, one per class.
The cells of a `GameMap` are in row order: the cell at (x, y) is at
`y * width + x`.

<!-- keys:start -->
- `Game`: `difficulty`, `factions`, `humanPlayerId`, `leviathanReturn`, `replay`, `status`, `turn`
- `Player`: `baseX`, `baseY`, `buildings`, `eventState`, `fallen`, `historyEntries`, `id`, `intel`, `name`, `objectiveState`, `pendingExplorations`, `pendingReinforcements`, `raidState`, `recruitedUnitTypes`, `resources`, `revealedCellsPerLevel`, `techBranches`, `unitsPerLevel`, `volcanoState`, `worksite`
- `ObjectiveState`: `completed`, `seenTips`, `tipsEnabled`, `tutorialEnabled`
- `ReplayJournal`: `actions`, `endTurnSeeds`, `exact`, `mapSeed`, `playerName`
- `Resource`: `amount`, `maxStorage`, `type`
- `Building`: `level`, `type`
- `TechBranchState`: `branch`, `choices`, `researchLevel`, `unlocked`
- `Unit`: `count`, `type`
- `Worksite`: `research`, `upgrades`
- `GridPosition`: `x`, `y`
- `MonsterLair`: `difficulty`, `family`, `secondCount`, `secondFamily`, `unitCount`
- `TransitionBase`: `capturedBy`, `name`, `type`
- `MapCell`: `collectedBy`, `content`, `lair`, `passageName`, `terrain`, `transitionBase`
- `GameMap`: `cells`, `height`, `seed`, `width`
- `ExplorationOrder`: `level`, `target`
- `ReinforcementOrder`: `arrivalPoint`, `departTurn`, `fromLevel`, `toLevel`, `units`
- `AnnouncedAttack`: `arrivalTurn`, `attackerId`, `seed`, `units`
- `RaidState`: `arrivalTurn`, `attacks`, `incoming`, `kernelAttackTurns`, `kernelSiegeLostTurn`, `lostInARow`, `noise`, `postAttackTurns`, `raidsLost`, `raidsRepelled`, `totalNoise`
- `VolcanoState`: `arrivalTurn`, `incoming`, `levelsLost`, `wavesRepelled`
- `EventState`: `active`, `activeUntilTurn`, `eventsSeen`, `heating`, `lastDrawn`, `nextDrawTurn`, `pending`, `pendingTurn`, `predatorWave`, `predatorsTurn`, `survivors`, `tradeFrom`, `tradeTo`, `wreckPosition`, `wreckUntilTurn`
- `LeviathanReturn`: `at`, `level`, `over`, `postName`, `readyTurn`, `strikeTurn`
- `BaseIntel`: `army`, `headquartersLevel`, `rampartLevel`, `stocks`, `turn`
- `Combatant`: `atk`, `currentHp`, `def`, `isBoss`, `maxHp`, `side`, `typeKey`
- `FightTurnSummary`: `attacksPlayed`, `critCount`, `damageDealtByMonster`, `damageDealtByPlayer`, `monsterAliveAtEnd`, `monsterHpAtEnd`, `playerAliveAtEnd`, `playerHpAtEnd`, `turnNumber`
- `FightResult`: `finalMonsterCount`, `finalPlayerCombatants`, `initialMonsterCount`, `initialPlayerCombatants`, `turnCount`, `turnSummaries`, `winner`
- `BuildingEntry`: `buildingType`, `category`, `newLevel`, `turn`
- `CollectEntry`: `category`, `gains`, `targetX`, `targetY`, `turn`
- `ExploreEntry`: `category`, `targetX`, `targetY`, `turn`
- `RecruitEntry`: `category`, `quantity`, `turn`, `unitType`
- `ResearchEntry`: `branch`, `category`, `isUnlock`, `newLevel`, `turn`
- `TurnResourceChange`: `afterAmount`, `beforeAmount`, `consumed`, `produced`, `type`, `wasCapped`
- `TurnEndEntry`: `category`, `changes`, `deactivatedBuildings`, `lostUnits`, `turn`
- `DescentEntry`: `category`, `targetLevel`, `turn`, `unitCount`
- `ReinforcementEntry`: `category`, `targetLevel`, `turn`, `unitCount`
- `EventEntry`: `accepted`, `category`, `defaulted`, `turn`, `type`
- `CombatEntry`: `category`, `dead`, `fightResult`, `lair`, `loot`, `sent`, `survivorsIntact`, `targetX`, `targetY`, `turn`, `victory`, `wounded`
- `CaptureEntry`: `captured`, `category`, `fightResult`, `transitionBaseName`, `turn`
- `RaidEntry`: `category`, `dead`, `defenders`, `fightResult`, `loot`, `pillaged`, `rampartLevel`, `surprise`, `survivorsIntact`, `turn`, `victory`, `wave`, `wounded`
- `VolcanoEntry`: `category`, `dead`, `defenders`, `fightResult`, `kernelLevel`, `survivorsIntact`, `turn`, `victory`, `wave`, `wounded`
- `BaseAssaultEntry`: `category`, `dead`, `defending`, `fightResult`, `headquartersAfter`, `headquartersBefore`, `loot`, `lostWithPost`, `opponentName`, `passageDestroyed`, `pillaged`, `postName`, `rampartAfter`, `rampartBefore`, `survivorsIntact`, `turn`, `units`, `victory`, `wounded`
<!-- keys:end -->

The value of each key is in the snapshots of `lib/domain/reference/snapshots/`,
one `ClassSnapshot` per class; each follows the rules above.

### Fields left out

Every persisted field is written, but these:

| Field | Why |
|---|---|
| `Game.createdAt`, `Game.savedLastPlayedAt` | Wall-clock dates; only the list of saves reads them. |
| `Game.players`, `Game.levels` | Not left out: written as the sections of the players and `map1`, `map2`, `map3`. |
| `title` of a history entry (all classes but `BaseAssaultEntry`) | Always empty: the presentation words the entry. The field only keeps the layout of old Hive saves, and the port drops it. |
| `subtitle` of a history entry (same classes) | Never set by the rules, always `null` in a game started today: a French line some older versions saved. The port drops it. |

### The completeness guard

`test/domain/reference/snapshot_completeness_test.dart` reads the source of
every `@HiveType` class under `lib/` and compares its `@HiveField` fields
with what the snapshot of that class declares: the fields it writes, plus the
fields it leaves out, each with its reason. A persisted field added to the
model, or a new persisted class, fails that test until the snapshot writes it
(or says why not). The same test checks that every field of `Game` and of
`Player` is in exactly one section, and that the lists of this file are the
ones of the code.
