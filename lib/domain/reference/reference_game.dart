import '../action/action_type.dart';
import '../event/random_event_type.dart';
import '../game/game_status.dart';
import 'digest_rows.dart';
import 'reference_layout.dart';
import 'reference_recorder.dart';
import 'reference_source.dart';
import 'snapshot_sections.dart';

/// A reference game: how it was produced, the journal that replays it,
/// and the digest of every section of its state turn after turn. The
/// format of its file is specified in `reference/README.md`.
class ReferenceGame {
  /// Version of the file format.
  static const int format = 1;

  static const ReferenceLayout _layout = ReferenceLayout(<String>{
    '',
    'turns',
    'journal',
    'journal.turns',
  });

  final ReferenceSource source;

  /// The game as `ReplayExport` writes it: every action with the seed of
  /// its dice, and the seed of every end of turn.
  final Map<String, Object?> journal;

  /// The digests at the start of turn 1, then after each end of turn.
  final List<TurnDigests> turns;

  /// The digests when the game stopped: those of the last of [turns]
  /// unless actions were played since.
  final List<String> finalDigests;

  final Map<ActionType, int> actions;
  final Map<RandomEventType, int> events;

  /// How far the game went (see `ReferenceMilestones`).
  final Map<String, Object?> milestones;
  final GameStatus status;

  /// The turn the game stopped on.
  final int turn;

  const ReferenceGame({
    required this.source,
    required this.journal,
    required this.turns,
    required this.finalDigests,
    required this.actions,
    required this.events,
    required this.milestones,
    required this.status,
    required this.turn,
  });

  Map<String, Object?> toJson() {
    final List<List<String>> rows = DigestRows.compact(<List<String>>[
      for (final TurnDigests t in turns) t.digests,
    ]);
    return <String, Object?>{
      'format': format,
      'source': source.toJson(),
      'result': <String, Object?>{'status': status.name, 'turn': turn},
      'coverage': <String, Object?>{
        'actions': <String, int>{
          for (final ActionType t in ActionType.values)
            if (actions.containsKey(t)) t.name: actions[t]!,
        },
        'events': <String, int>{
          for (final RandomEventType t in RandomEventType.values)
            if (events.containsKey(t)) t.name: events[t]!,
        },
        'milestones': milestones,
      },
      'sections': SnapshotSections.names,
      'turns': <Object?>[
        for (int i = 0; i < turns.length; i++)
          <String, Object?>{'turn': turns[i].turn, 'digests': rows[i]},
      ],
      'final': finalDigests,
      'journal': journal,
    };
  }

  /// The file of the game, one line per turn.
  String get text => _layout.write(toJson());
}
