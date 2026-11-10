# tool/samples

What the tests of `godot/domain` build again and again: the buildings of a
base, an army, a stock of resources. Test infrastructure, not game code, left
out of exports and of the coverage.

`DomainSamples` holds the helpers the Dart tests repeat in each file
(`_buildings`, `_units`, `_base`, `_resources`): each takes a map by enum
value and gives the typed map the rules take, with the entries given and
only them, in the order given.

    var buildings := DomainSamples.buildings({BuildingType.Value.HEADQUARTERS: 2})

`TechHelpers` is `test/helpers/tech_helpers.dart`, a file of helpers the Dart
tests already share: a researched branch, the three branches of a player.

`MapSamples` builds bare cells and maps, and reads a map as the Dart tests
do through `test/helpers/`: the cells that hold a content, the posts as the
passages of the level below, the distance between two cells and the
fingerprint that pins a generated map (`mapFingerprint`).

`GameSamples` builds the players and games the Dart tests write inline: a
player named after its id (`player`), one holding only the buildings given
(`player_with`), a game whose human is the first player given (`game`), and
`two_players`, the twin of `test/helpers/two_player_game.dart`. A game from a
seed comes from `GameFactory` itself.

`HistorySamples` builds the entries of the fights of
`test/helpers/history_entry_samples.dart` and the fight of two turns they
hold (`buildTestFight`, its `fight` here), and the fights, combats and
game of `test/domain/game/game_statistics_helper.dart` (`statistics_*`).

`EventSamples` builds what the tests of the random events take from
`test/domain/event/event_test_helper.dart`,
`effects/wreck_test_helper.dart` and `effects/predators_test_helper.dart`:
a player and its game, the 9x9 map of the wreck with the player who
explored its centre, and the player whose predators wait for a choice.

The tests driven by `reference/vectors/` build theirs from the Dart names a
case writes, with `VectorInputs` (`godot/tool/reference/README.md`).

`RaidSamples` builds the bases and kernels the raids and the krakens strike,
as `test/domain/raid/raid_test_helper.dart` does: a player holding 1000 of
every resource with the units, the Citadel and the headquarters given
(`raid_player`), and the units standing on its base (`units_on_base`); a
player whose kernel holds a garrison (`volcano_player`, as
`volcano_test_helper.dart`), the game of `kernel_garrison_helpers.dart`
(`kernel_garrison_game`), and `set_units` of `objective_helpers.dart`.

`RaidDigests` writes the short texts the digest tests compare with what a
scratch Dart script printed on the games of `GameFactory`: a wave, a raid
report, a raid state with the stocks and the units, and the army the
players get first (`arm_for_raids`).

`HistoryDigests` writes the history entries the players of those games
hold, for the same comparison: the number of entries after each turn, then
each entry, its maps as `name:count` in their order. `RaidHistories` and
`VolcanoHistories` hold what the Dart script printed for the raid and the
volcano digests, too long to sit in their test files.

`EventDigests` does the same for the digest test of the random events: it
makes the players' choices as `ChooseEventAction` does, and writes what a
draw left, a school of predators fought and the state of the events;
`EventHistories` holds the history entries the Dart script printed.

`ObjectiveSamples` builds what the tests of the objectives take from
`test/helpers/objective_helpers.dart` and `map_tab_harness.dart`: the game
of a new player on a plain 10x10 map (`objective_game`), a building set to
a level, and the progress `expectProgress` compares, as
`[current, target, done]`. `tip` and `applies` stand for
`TipCatalog.byId(id)`, which waits for the tips of the posts: they read a
tip from its list.

`ObjectiveDigests` serves the digest test of the objectives
(`objective_resolver_digest_test.gd`): it develops each player of the
games of `GameFactory` between the turns as the scratch Dart script did
(a building, units, research, cells revealed, raids, history entries, a
lair, a Faille and a kernel taken), and writes an objective completed
with what it credited, an objective of an event under way or ended, and
the tips ported that newly apply, in the order of `TipId`.

`ActionSamples` builds what the tests of the actions write inline (`Player(id:
'test', name: 'Test', resources: ..., buildings: ...)`, a player stocked with
the amounts and buildings given and its game) and, as the actions come, what
the helpers of `test/domain/action/` build.

`MoveSamples` builds the games of the actions that move units from one level
to another: the descent of `descend_action_helper.dart` (`descend_game`), the
reinforcements of `send_reinforcements_helper.dart` (`reinforcement_map`,
`reinforcement_game`) and the volcano of `volcano_test_helper.dart`
(`volcano_game`), whose player `RaidSamples.volcano_player` builds.

`AssaultSamples` is the twin of `test/helpers/base_attack_helper.dart`: the
two-player game at turn 12 where the human has seen the rival's base
(`assault_game`, `rival_of` for `two.rival`), `set_level`, `station` and
`standing`, `strike` (the human's attack on the rival's base), and the
armies `HORDE` and `WALL`; the game of `announce_attack_helper.dart`
(`announce_game`, its army `RAIDERS`, and `announce`, the rival's attack
on the human); and the player of
`test/domain/fight/assault/assault_test_helper.dart` (`assault_player`).

`PostWar` and `KernelWar` are the twins of the classes of
`test/helpers/post_attack_helper.dart` and `kernel_war_helper.dart`: a game
against two factions at turn 12 where one faction (or the human) holds a
post with its passage, or the volcanic kernel, and the other stands ready
to strike, with the armies of those files as constants; `strike` is the
attack on the post, or on the kernel, with its dice `SeededRandom(seed)`.

`WarDigests` writes what the digest test of the wars between players
(`war_digest_test.gd`) compares, an attack on a post or on a held kernel,
the last assault entry of a player and the attacks pending on the human
base, and plays the attacks the factions decide (`announces`);
`WarHistories` holds what the scratch Dart script printed.

`SiegeSamples` builds the games of the assaults on what nobody holds yet,
as `attack_transition_base_helper.dart` (`attack_game`) and
`attack_volcanic_kernel_helper.dart` (`kernel_game`) do: a 5x5 map with
the post or the kernel on (1, 1), the player `test-uuid` and its stock.
`SiegeDigests` writes what the digest test of the sieges
(`siege_digest_test.gd`) compares, an assault on the kernel or an attack on
a base, and `SiegeHistories` holds what the scratch Dart script printed.

`ActionDigests` writes the digest of an action that the digest test of the
actions compares with what a scratch Dart script printed on the games of
`GameFactory`: its outcome, the stocks, the units, the buildings, the cells
revealed and collected, the noise, the pending orders and the last history
entry; it also picks the first target an action may take, row by row.
`ActionHistories` holds what the Dart script printed.
