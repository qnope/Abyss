# data

Saving and loading: turning the domain's state into a versioned save and back,
and the settings kept across launches.

Depends on `domain/` only. The domain never depends on this layer.

The saves start over with the Godot version: no Hive save of the Flutter
version is read. A save keeps what the Dart Hive adapters keep (the
`@HiveField`s of `lib/domain`), no more, and a game loaded here is the game
Flutter loads from Hive: it plays on to the same turns, to the last die.

## The save format

`save/`: one codec per area of the domain, each a pair of static functions,
`thing(x) -> Dictionary` that writes and `read_thing(reader, value)` that
reads back.

| Codec | Classes |
| --- | --- |
| `SaveCodec` | the envelope: `{"format":1,"game":{...}}`, the text of a save and back |
| `GameCodec` | `Game` |
| `PlayerCodec` | `Player` |
| `BaseCodec` | `Resource`, `Building`, `TechBranchState`, `Unit`, `Worksite`, `ObjectiveState` |
| `MapCodec`, `OrderCodec` | `GridPosition`, `MonsterLair`, `TransitionBase`, `MapCell`, `GameMap`; `ExplorationOrder`, `ReinforcementOrder` |
| `ThreatCodec`, `EventCodec` | `AnnouncedAttack`, `RaidState`, `VolcanoState`, `LeviathanReturn`, `BaseIntel`; `EventState` |
| `FightCodec` | `Combatant`, `FightTurnSummary`, `FightResult` |
| `HistoryCodec`, `HistoryFightCodec` | every `HistoryEntry`, `TurnResourceChange` |
| `JournalCodec` | `ReplayJournal` |

The text is JSON on one line (`jq .` shows it indented), stable from one save
to the next of the same game:

- An object has one key per persisted field, named as the Dart field
  (`maxStorage`, `lostInARow`), the `saved` of the fields Dart keeps nullable
  for its old saves left out (`difficulty`, `factions`, `lastPlayedAt`,
  `objectiveState`, `fallen`, `intel`). The `seed` of a `GameMap` and of an
  `AnnouncedAttack` keeps its Dart name. Every key is written, `null`
  included, and every key is required to read: a save is never half read.
- An enum value is its Dart name (`"algaeFarm"`, `"freePlay"`).
- A map keeps its order, which is state (an army fights in it): a map by
  enum value or by player id is an object in that order, a map by level or by
  turn an object keyed by the digits of the number (`"levels":{"1":{...}}`).
  `JSON.stringify(x, "", false)` writes the keys in that order and Godot's
  parser reads them back in it.
- A whole number is written as one. Godot's JSON reads every number as a
  float: `SaveReader` turns a whole one back into an int, and refuses one that
  is not whole or is past 2^53, which a float does not hold exactly (no state
  comes near it: the seeds are below 2^31). The state holds no double.
- A date (`createdAt`, `lastPlayedAt`) is a whole number of milliseconds since
  1970-01-01 UTC, what Hive keeps of a `DateTime`.
- A move of the journal stays the JSON text the journal recorded.
- A history entry starts with its `turn` and its `category`, which tells the
  classes apart.

### What a save does not keep

What Dart does not persist comes back as Dart's Hive load leaves it, because
each object is read through its constructor as the Dart adapter reads it:

| Field | Comes back |
| --- | --- |
| `role`, `family` of a `Combatant` | computed again by the constructor from the type, as Dart's `late final`s |
| `maxStorage` of the energy `Resource` | lifted to its minimum by the constructor, as Dart's |
| `title`, `subtitle` of a history entry | not in the port (`domain/README.md`, "No Hive") |

Nothing is shared between two objects after a load, as after a Hive load: an
object the game reached twice is written, and read, twice.

### Reading, and refusing

`SaveCodec.from_text` gives a `DecodedSave`: the game, or the reason it was
refused. It never stops on a bad save and never logs an error: `SaveReader`
reads each value through a check that notes the first problem (a missing
field, a value of the wrong type, an unknown enum name, a key that is not a
number) and gives a default in its place, and the save is refused once read.
It refuses a text that is no JSON or is cut short (`not a save: ...`), a
format it does not know (`unknown format 0`), a newer one (`saved by a newer
version (format 2, this one reads up to 1)`), and a game whose human is not
among its players.

### Version policy

`SaveCodec.FORMAT` is the format this version writes and the newest it
reads, 1 for now. A change that a save of the current format cannot hold as
it is (a new persisted field, a renamed one, a new class) raises `FORMAT` by
one, and the codec reads every older format: a migration per version,
`format k` to `k + 1` on the parsed JSON before the codecs read it (the new
field given the value the Dart adapter gives a missing one, as its
`fields[n] == null ? default : ...`), applied in turn from the save's
format up. The save is written back in the new format at its next save. A
save of a newer format is never read, so an older version never damages
what a newer one wrote.

## The saves folder

`repository/`: `GameRepository` is `lib/data/game_repository.dart`. Each game
is a file of its own in `user://saves/`, `game-<n>.json`, `n` counting up from
1 past the highest file there, as Hive numbers what it adds to a box; the
games load in that order. One file per game and no index: nothing to keep in
step, and a file that cannot be read loses that game only. `load_all` gives
`SavedGames`, the games and the files it skipped with why, never stopping on
one. The repository keeps the file of each game it saved or loaded, so that
saving it again replaces that file, as Hive saves a game already in its box;
`delete_game` removes it.

`save` stamps the game as last played (`now`, a `Callable` the tests replace)
and writes it through `AtomicFile`: the whole text to `game-<n>.json.tmp`,
then a rename over the save. A crash or a full disk while writing leaves the
previous save whole; a `.tmp` left behind is ignored, and replaced by the next
save of that game.

## The settings

`settings/`: `LanguageSettings` is `lib/data/language_settings.dart`: the
`LanguageChoice` of the player in `user://settings.json`,
`{"format":1,"language":"fr"}`, the language left out while the device
decides. A file missing, unreadable, of another format or holding an unknown
code reads as the device's language; its `changed` signal tells each real
change.

## Tests

Each codec is tested by writing objects, parsing the text and reading them
back, compared through the snapshot of their class (`CodecTestCase`,
`tool/reference/`). The files are written in a folder of `user://` of their
own (`TempFolder`, `tool/samples/`), removed after each test. The whole games
go through their saves in `tool/reference/save_round_trip_test.gd` (two short
reference games, saved and loaded at every turn, played on from three turns)
and in the long cases `saves-<game>` of `tool/godot_reference.sh`, one per
reference game (`tool/replay/README.md`).
