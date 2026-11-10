import '../../replay/replay_journal.dart';
import '../class_snapshot.dart';
import '../snapshot_values.dart';

/// Snapshot of the journal a game keeps of its own moves.
abstract final class JournalSnapshots {
  /// The actions are decoded, each one the list of its pairs in the order
  /// the journal wrote them (`do` first; the units in the order they were
  /// sent), so no JSON layout is part of the snapshot.
  static final ClassSnapshot<ReplayJournal> journal =
      ClassSnapshot<ReplayJournal>('ReplayJournal', {
        'mapSeed': (j, _) => j.mapSeed,
        'playerName': (j, _) => j.playerName,
        'actions':
            (j, _) => <Object?>[
              for (final int turn in j.actions.keys)
                <Object?>[turn, SnapshotValues.ordered(j.actionsOf(turn))],
            ],
        'endTurnSeeds':
            (j, _) => SnapshotValues.pairs<int, int>(
              j.endTurnSeeds,
              (int turn) => turn,
              (int seed) => seed,
            ),
        'exact': (j, _) => j.exact,
      });
}
