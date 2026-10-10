import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../action/action.dart';
import '../action/end_turn_action.dart';
import 'action_encoder.dart';
import 'seeded_random.dart';

part 'replay_journal.g.dart';

/// Every move of a game, in the order it was played, with the seeds that
/// drove its dice: enough to replay the game turn for turn.
///
/// Every player's moves share one list per turn, in the order played; a
/// move of a player other than the human carries a `player` key.
///
/// Unlike the history shown to the player, the journal is never trimmed.
/// `ActionExecutor` fills it as actions succeed; `ReplayExport` turns it
/// into a scenario that `bin/simulate.dart` plays headless.
@HiveType(typeId: 45)
class ReplayJournal {
  @HiveField(0)
  final int mapSeed;

  @HiveField(1)
  final String playerName;

  /// JSON-encoded actions (see `ActionEncoder`) per turn.
  @HiveField(2)
  final Map<int, List<String>> actions;

  /// Seed of the generator that drove each end of turn (raids).
  @HiveField(3)
  final Map<int, int> endTurnSeeds;

  /// Whether every die rolled so far came from a recorded seed.
  @HiveField(4)
  bool exact;

  ReplayJournal({
    required this.mapSeed,
    required this.playerName,
    Map<int, List<String>>? actions,
    Map<int, int>? endTurnSeeds,
    this.exact = true,
  }) : actions = actions ?? <int, List<String>>{},
       endTurnSeeds = endTurnSeeds ?? <int, int>{};

  /// Notes that [action] succeeded during [turn]. The human player's
  /// actions carry no player; any other player's carry its [playerId].
  void record(int turn, Action action, {String? playerId}) {
    if (action is EndTurnAction) {
      final random = action.random;
      if (random is SeededRandom) {
        endTurnSeeds[turn] = random.seed;
      } else {
        exact = false;
      }
      return;
    }
    final Map<String, Object?>? json = ActionEncoder.encode(action);
    if (json == null) return;
    if (!ActionEncoder.isExact(action)) exact = false;
    final Map<String, Object?> entry = <String, Object?>{
      ...json,
      if (playerId != null) 'player': playerId,
    };
    (actions[turn] ??= <String>[]).add(jsonEncode(entry));
  }

  /// Decoded actions of [turn], oldest first.
  List<Map<String, Object?>> actionsOf(int turn) => <Map<String, Object?>>[
    for (final String a in actions[turn] ?? const <String>[])
      jsonDecode(a) as Map<String, Object?>,
  ];
}
