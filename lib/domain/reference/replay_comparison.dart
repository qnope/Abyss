import 'reference_recorder.dart';
import 'snapshot_sections.dart';

/// Checks that the replay of a journal went through the same states as
/// the game the journal comes from, and says where it did not.
abstract final class ReplayComparison {
  /// Throws a [StateError] naming the sections whose digests differ.
  static void same(String when, List<String> played, List<String> replayed) {
    final List<String> differing = <String>[
      for (int i = 0; i < played.length; i++)
        if (played[i] != replayed[i]) SnapshotSections.names[i],
    ];
    if (differing.isNotEmpty) {
      throw StateError('The replay differs $when: ${differing.join(', ')}');
    }
  }

  /// Throws a [StateError] on the first turn that started differently.
  static void sameTurns(List<TurnDigests> played, List<TurnDigests> replayed) {
    if (played.length != replayed.length) {
      throw StateError(
        'The replay differs: ${replayed.length} turns started, '
        '${played.length} in the game',
      );
    }
    for (int i = 0; i < played.length; i++) {
      same(
        'at the start of turn ${played[i].turn}',
        played[i].digests,
        replayed[i].digests,
      );
    }
  }
}
