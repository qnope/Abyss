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
hold (`buildTestFight`, its `fight` here).

The tests driven by `reference/vectors/` build theirs from the Dart names a
case writes, with `VectorInputs` (`godot/tool/reference/README.md`).
