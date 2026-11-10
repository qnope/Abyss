# Reference games

The rules of ABYSSES are being ported from Dart (`lib/domain`) to GDScript
(`godot/domain`), and the port must play **exactly the same game**. The proof
is here: games played by the Flutter rules, each with the journal of its
moves and, turn after turn, a digest of every part of its state. The Godot
port replays the journal and must find the same digests.

This file specifies the format, so that GDScript writes the very same bytes.
The Dart side lives in `lib/domain/reference/`.

Beside the games, `reference/vectors/` holds inputs and outputs of single
pieces of the rules (Dart's random generator, sort and arithmetic, costs,
fights, maps...), for the modules ported before a whole game can be replayed:
see `reference/vectors/README.md`. CI's `Reference` job checks both.

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
produces the texts: `GameSnapshot.digests` is given the digest function. The
SHA-256 comes from the `crypto` package, a development dependency used by the
export tool and the tests (`tool/reference/sha256_hex.dart`), so the app does
not depend on it.

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

## A reference game

A file of `reference/games/` is one game (`ReferenceGame`), in JSON, one line
per turn so that a change of the rules shows as the turns it changes:

```
{
"format":1,
"source":{"strategy":"conquest","seed":3,"difficulty":"normal","factions":[],"turns":100},
"result":{"status":"victory","turn":90},
"coverage":{"actions":{"upgradeBuilding":57,...},"events":{"storm":3,...},"milestones":{...}},
"sections":["buildings","events","fog","game",...],
"turns":[
{"turn":1,"digests":["ad9a23a5...","83799caf...",...]},
{"turn":2,"digests":["=","=","c1f0...",...]},
...
],
"final":["4be1...",...],
"journal":{
"name":"replay-conquest-tour-90",
"player":"conquest",
"mapSeed":1366551624,
"difficulty":"normal",
"lastTurn":90,
"exact":true,
"status":"victory",
"turns":{
"1":[{"do":"upgrade","building":"headquarters"}],
...},
"endTurnSeeds":{"1":1575319661,...}
}
}
```

- `source` is what produced the game, and all it takes to produce it again:
  a `strategy` of the simulator or a `scenario` file (a path from the root of
  the repository), the `seed`, the `difficulty`, the `factions` (personalities
  in playing order) and the limit of `turns`. A scenario that pins its own
  difficulty, factions or last turn (an exported replay) keeps them.
- `journal` is the game in the format the app exports and
  `bin/simulate.dart --scenario` replays (`ReplayExport`): every successful
  action of every player, turn by turn, in the order played, with the `seed`
  of its dice when it rolls some, and the seed of every end of turn. It also
  holds the map seed, the difficulty, the name of the player and the factions.
  `exact` is always true: the export fails otherwise.
- `sections` names the sections, in the order of every list of digests.
- `turns` holds the digests of the state **at the start of turn 1, then after
  each end of turn**: the entry of turn *n* is the state as turn *n* starts.
  A digest equal to the one of the same section in the entry before is
  written `"="`.
- `final` holds the digests when the game stopped, always in full. They are
  those of the last entry of `turns` unless actions were played in the last
  turn: a game won by an action stops there, without ending its turn, and so
  does a replay on its `lastTurn`.
- `result` is the status (`playing` when the game reached the turn limit) and
  the turn it stopped on.
- `coverage` tells what the game went through, for the test of the set:
  the successful actions by `ActionType` (ends of turn included, those of
  the factions too), the random events drawn by type (for any player), and
  `milestones`: the turn the human took a Faille, a Cheminée and the kernel,
  the turn the guardians struck back and whether the Faille held, the raids
  and kraken waves won and lost, the factions fallen, and the winner.

### Replaying it

The digests are those of a **replay of the journal**, the way
`ScriptRunner` plays a `TimelineScript`; the export checks that this replay
ends in the very state of the game first played. A replay goes:

1. Create the game from the journal: `player`, `mapSeed`, `difficulty`,
   `factions` (`GameFactory.newGame`). Compare with the entry of turn 1.
2. For each turn, play the actions of `journal.turns[turn]` in order, each
   one as its `player` (a faction id) or as the human when it has none,
   through `ActionExecutor`, with `SeededRandom(seed)` when it has a `seed`.
   After each successful action, `VictoryChecker.check` may end the game.
3. Stop on `lastTurn`, or when the human won. When a faction won (the
   status is `defeat`), the actions left in the turn are not played, and the
   turn still ends when `endTurnSeeds` holds it: the faction tamed the
   volcano while that turn ended, and the game resolved the rest of it
   (`conquest-hard-3-factions`). Otherwise end the turn:
   `EndTurnAction(random: SeededRandom(endTurnSeeds[turn]), playFactions:
   false)`, the brains of the factions do not play, their moves are in the
   journal. Compare with the entry of the next turn, and stop if the game
   is over.
4. Compare with `final`.

The state does not depend on the id of the human. A reference game is
*played* with the human id `00000000-0000-4000-8000-000000000000`
(`ReferenceExporter.humanId`), because a faction breaks a tie between two
bases by comparing ids, and a strategy game must be the same every time.

A strategy rolls its dice as `SeededScript` says: one generator,
`Random(seed)`, gives a fresh seed to every action that asks for dice, in
the order asked, and to every end of turn; the map seed is the first draw
of another `Random(seed)`. That is what the Godot strategies will have to
do to play these games again by themselves, not only to replay them.

## The games

`reference/games/` holds the games below. The turn is the one the game
stopped on: a game still `playing` reached its limit of turns, or the last
turn of the replay it comes from.

<!-- games:start -->
| Game | Played by | Seed | Difficulty | Factions | Result |
|---|---|---|---|---|---|
| `balanced-normal-2-factions` | balanced | 24 | normal | 2 | defeat, turn 86 |
| `balanced-normal` | balanced | 2 | normal | 0 | defeat, turn 84 |
| `conquest-easy-1-faction` | conquest | 1 | easy | 1 | victory, turn 83 |
| `conquest-hard-3-factions` | conquest | 39 | hard | 3 | defeat, turn 109 |
| `conquest-hard` | conquest | 13 | hard | 0 | victory, turn 101 |
| `conquest-normal-10-factions` | conquest | 29 | normal | 10 | playing, turn 101 |
| `conquest-normal` | conquest | 3 | normal | 0 | victory, turn 90 |
| `economy-hard` | economy | 11 | hard | 0 | defeat, turn 27 |
| `every-research-option-b` | `reference/scenarios/every-research-option-b.json` | 8 | normal | 0 | playing, turn 111 |
| `faille-lost-to-the-leviathan` | `reference/scenarios/faille-lost-to-the-leviathan.json` | 3 | normal | 0 | playing, turn 101 |
| `idle-normal-10-factions` | idle | 28 | normal | 10 | defeat, turn 45 |
| `idle-normal` | idle | 6 | normal | 0 | defeat, turn 48 |
| `plan85-easy` | plan85 | 7 | easy | 0 | defeat, turn 108 |
| `reinforcements-and-withdrawal` | `reference/scenarios/reinforcements-and-withdrawal.json` | 3 | normal | 0 | playing, turn 101 |
| `replay-victoire-tour-84` | `scenarios/replays/victoire-tour-84.json` | 1 | easy | 0 | playing, turn 84 |
| `replay-victoire-tour-85` | `scenarios/replays/victoire-tour-85.json` | 1 | normal | 0 | playing, turn 85 |
| `rush-easy` | rush | 14 | easy | 0 | defeat, turn 29 |
| `tutorial-easy-2-factions` | tutorial | 26 | easy | 2 | playing, turn 121 |
| `tutorial-normal` | tutorial | 5 | normal | 0 | victory, turn 92 |
<!-- games:end -->

The strategies are those of `bin/simulate.dart` (`ScriptLibrary`). The games
played by a file:

- `scenarios/replays/victoire-tour-84.json` and `victoire-tour-85.json` are
  two games a human won in the app, with their own map and dice (the seed of
  the source plays no part). The rules changed since: from turn 25 or so
  many of their actions are refused today, and neither is a victory any
  more. They are kept for what a human plays and a strategy does not, and
  their journal here holds the actions that still succeed.
- `reference/scenarios/reinforcements-and-withdrawal.json` lets `conquest`
  play, but sends reinforcements to a lower level three times (once from
  level 2 to level 3) and calls a part of the garrison of the base back
  (`withdraw`): no strategy does either.
- `reference/scenarios/faille-lost-to-the-leviathan.json` lets `conquest`
  play but leaves turn 35 empty, the turn the guardians strike back at the
  Faille the player took: the Faille is lost, which no strategy game of the
  set lets happen.
- `reference/scenarios/every-research-option-b.json` lets `conquest` play
  but researches the five levels of the three branches with option B at
  every choice, where the strategies take A at most of them.

`test/domain/reference/reference_set_test.dart` and
`reference_scenarios_test.dart` read these files and check that, together,
they execute every `ActionType`, draw every `RandomEventType`, end in every
status a scripted game can end in, are played at every difficulty and
against every faction, win and lose a raid, a kraken wave and the Faille,
see a faction fall and a faction win. `reference_set_fresh_test.dart` plays
the four shortest games again at every run of the tests; `--check` plays
them all.

Measured when the set was made, and not guarded by a test: the games also
build every building, recruit every unit, write every class of history
entry, accept, decline and let pass every event that asks a question, fight
the four families of monsters of the lairs, in easy, medium and hard lairs,
and win and lose base assaults on both sides.

### What the set does not cover

- **`GameStatus.freePlay`**: only the victory screen sets it, no rule does.
- **The guide.** A scripted game is created with the tutorial and the tips
  off, and the journal does not say otherwise: `tutorialEnabled` and
  `tipsEnabled` stay false and `seenTips` empty. So the one rule that reads
  the tutorial flag is never on: a base that cannot be attacked while its
  player has not finished the installation objectives
  (`AttackBaseValidator.isProtected`).
- **Refused actions.** A journal holds the actions that succeeded. A replay
  never asks a validator to refuse anything; only a strategy playing by
  itself does.
- **The brains and the strategies, by a replay.** In a replay the factions
  do not think (`playFactions: false`): their moves are read from the
  journal. A replay proves how actions and ends of turn resolve. To prove
  the brains of the factions and the strategies, play the game again from
  its `source` and compare the journal as well.
- **Saves of older versions**: the fields a migration fills, the `null`
  `saved...` fields, the texts of old history entries. Every game starts
  from `GameFactory.newGame`.
- **The cheat code** of the player named `qnope` (`CheatCodes`).
- **Games longer than 121 turns.**
- **Every roll of every die.** Nineteen games draw what they draw: a branch
  taken once in a thousand rolls may be in none. A rule is pinned for good
  by vectors of its own, not by these games.

## The tool

```
# One game
dart run bin/export_reference.dart --strategy conquest --seed 3 \
    --difficulty hard --factions 3 --turns 120 --out reference/games/x.json
dart run bin/export_reference.dart --scenario reference/scenarios/y.json \
    --seed 3 --turns 100 --out reference/games/y.json

# The committed set: played again, compared byte for byte
dart run bin/export_reference.dart --check     # fails naming what differs
dart run bin/export_reference.dart --update    # after a meant change of rules

# Where does a replay go wrong?
dart run bin/export_reference.dart --reference reference/games/x.json \
    --dump-turn 37 --trace-turn 36
```

`--factions` takes a number (drawn from the catalogue with the seed, as a new
game does) or names separated by commas.

`--dump-turn N` writes `<game>.turn-N.dump.json`: the canonical text of every
section at the start of turn N (`final` for the last state), one section per
line, `"name":` then the text whose SHA-256 is the digest. Dump the same turn
on the other side and compare the two files (`jq .` makes them readable).

`--trace-turn N` writes `<game>.turn-N.trace.json`: the digests at the start
of turn N, after **each action** of the turn (those of the factions
included, as the journal lists them), and after its end (`null` when the
game stopped in that turn).

`--check` plays every game of `reference/games/` again from its `source`
and compares the file byte for byte; when some differ it names them, writes
what they are today in a temporary folder, and exits with 1.
