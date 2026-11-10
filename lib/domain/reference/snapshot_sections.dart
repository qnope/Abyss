/// The sections a game snapshot is split in, so that two games that
/// differ tell where: each one is a group of fields of `Game` or of
/// `Player`, by their Dart names, or one level of the world.
abstract final class SnapshotSections {
  /// Sections made of fields of the game itself.
  static const Map<String, Set<String>> ofGame = <String, Set<String>>{
    'game': <String>{
      'humanPlayerId',
      'turn',
      'status',
      'savedDifficulty',
      'savedFactions',
    },
    'journal': <String>{'replay'},
    'leviathan': <String>{'leviathanReturn'},
  };

  /// Sections made of fields of every player, in playing order.
  static const Map<String, Set<String>> ofPlayers = <String, Set<String>>{
    'players': <String>{'name', 'id', 'baseX', 'baseY', 'savedFallen'},
    'resources': <String>{'resources'},
    'buildings': <String>{'buildings'},
    'worksite': <String>{'worksite'},
    'tech': <String>{'techBranches'},
    'units': <String>{'unitsPerLevel', 'recruitedUnitTypes'},
    'orders': <String>{'pendingExplorations', 'pendingReinforcements'},
    'fog': <String>{'revealedCellsPerLevel'},
    'raids': <String>{'raidState'},
    'volcano': <String>{'volcanoState'},
    'events': <String>{'eventState'},
    'objectives': <String>{'savedObjectiveState'},
    'intel': <String>{'savedIntel'},
    'history': <String>{'historyEntries'},
  };

  /// The levels of the world, each one a section named [ofLevel].
  static const List<int> levels = <int>[1, 2, 3];

  static String ofLevel(int level) => 'map$level';

  /// Every section, in the order a snapshot lists them: by name.
  static final List<String> names = List<String>.unmodifiable(
    <String>[
      ...ofGame.keys,
      ...ofPlayers.keys,
      for (final int level in levels) ofLevel(level),
    ]..sort(),
  );
}
