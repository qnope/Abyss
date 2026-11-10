import '../../game/game.dart';
import '../class_snapshot.dart';
import '../snapshot_values.dart';
import 'journal_snapshots.dart';
import 'threat_snapshots.dart';

/// Snapshot of what a game holds besides its players and its maps, which
/// `GameSnapshot` writes in sections of their own.
abstract final class GameSnapshots {
  static final ClassSnapshot<Game> game = ClassSnapshot<Game>(
    'Game',
    {
      'humanPlayerId': (g, ids) => ids.of(g.humanPlayerId),
      'turn': (g, _) => g.turn,
      'status': (g, _) => g.status.name,
      'replay': (g, ids) => JournalSnapshots.journal.orNull(g.replay, ids),
      'savedDifficulty': (g, _) => g.difficulty.name,
      'savedFactions': (g, _) => SnapshotValues.names(g.savedFactions ?? []),
      'leviathanReturn':
          (g, ids) => ThreatSnapshots.leviathan.orNull(g.leviathanReturn, ids),
    },
    renamed: const <String, String>{
      'savedDifficulty': 'difficulty',
      'savedFactions': 'factions',
    },
    omitted: const <String, String>{
      'players':
          'written by the sections of the players, one per group of '
          'Player fields (SnapshotSections.ofPlayers)',
      'levels': 'written by the sections map1, map2 and map3',
      'createdAt':
          'wall-clock date the game started; only the list of '
          'saves reads it',
      'savedLastPlayedAt':
          'wall-clock date of the last save; only the '
          'list of saves reads it',
    },
  );
}
