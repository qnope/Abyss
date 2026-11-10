import 'reference_game.dart';
import 'reference_layout.dart';
import 'reference_recorder.dart';
import 'snapshot_sections.dart';

/// What a reference game is asked for one turn, to find where a replay
/// goes wrong: the digests after each action of that turn ([trace]) or
/// the whole state at its start ([dump]).
abstract final class ReferenceTrace {
  /// The digests at the start of [turn], after each of its [actions] (as
  /// the journal holds them, those of the factions included), and after
  /// its end; `end` is null when the game stopped before.
  static String trace(
    ReferenceRecorder recorder,
    int turn,
    List<Map<String, Object?>> actions,
  ) {
    if (actions.length != recorder.traced.length) {
      throw StateError(
        'Turn $turn: ${actions.length} actions in the journal, '
        '${recorder.traced.length} executed',
      );
    }
    return const ReferenceLayout(<String>{'', 'actions'}).write(
      <String, Object?>{
        'format': ReferenceGame.format,
        'turn': turn,
        'sections': SnapshotSections.names,
        'start':
            _digestsAt(recorder, turn) ??
            (throw StateError('Turn $turn was not played')),
        'actions': <Object?>[
          for (int i = 0; i < actions.length; i++)
            <String, Object?>{
              'action': actions[i],
              'digests': recorder.traced[i],
            },
        ],
        'end': _digestsAt(recorder, turn + 1),
      },
    );
  }

  /// The canonical text of every section, one per line; [turn] is the
  /// turn it starts, or `final` for the state the game stopped in.
  static String dump(Object turn, Map<String, String> texts) =>
      const ReferenceLayout(<String>{'', 'sections'}).write(<String, Object?>{
        'format': ReferenceGame.format,
        'turn': turn,
        'sections': <String, Object?>{
          for (final MapEntry<String, String> e in texts.entries)
            e.key: RawJson(e.value),
        },
      });

  static List<String>? _digestsAt(ReferenceRecorder recorder, int turn) {
    for (final TurnDigests t in recorder.turns) {
      if (t.turn == turn) return t.digests;
    }
    return null;
  }
}
