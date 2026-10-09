import 'dart:convert';

import '../game/game.dart';
import 'replay_journal.dart';

/// Turns a game's [ReplayJournal] into a JSON scenario that
/// `ScenarioParser` reads and `bin/simulate.dart` plays headless:
///
/// ```json
/// {
///   "name": "replay-qnope-tour-12",
///   "player": "qnope",
///   "mapSeed": 1234,
///   "lastTurn": 12,
///   "exact": true,
///   "turns": {"1": [{"do": "upgrade", "building": "algaeFarm"}]},
///   "endTurnSeeds": {"1": 98765}
/// }
/// ```
abstract final class ReplayExport {
  /// Whether [game] kept a journal; games started before it existed did not.
  static bool canExport(Game game) => game.replay != null;

  static Map<String, Object?> toJson(Game game) {
    final ReplayJournal journal = game.replay!;
    final List<int> turns = journal.actions.keys.toList()..sort();
    final List<int> ends = journal.endTurnSeeds.keys.toList()..sort();
    return <String, Object?>{
      'name': fileName(game).replaceAll('.json', ''),
      'player': journal.playerName,
      'mapSeed': journal.mapSeed,
      'difficulty': game.difficulty.name,
      'lastTurn': game.turn,
      'exact': journal.exact,
      'status': game.status.name,
      'turns': <String, Object?>{
        for (final int t in turns) '$t': journal.actionsOf(t),
      },
      'endTurnSeeds': <String, int>{
        for (final int t in ends) '$t': journal.endTurnSeeds[t]!,
      },
    };
  }

  /// The scenario, indented so it reads well once shared.
  static String toText(Game game) =>
      const JsonEncoder.withIndent('  ').convert(toJson(game));

  static String fileName(Game game) {
    final String player = game.replay?.playerName ?? 'partie';
    final String safe = player.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    return 'replay-$safe-tour-${game.turn}.json';
  }
}
