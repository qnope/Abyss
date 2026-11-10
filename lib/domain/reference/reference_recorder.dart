import '../action/action.dart';
import '../action/action_result.dart';
import '../action/action_type.dart';
import '../action/end_turn_action.dart';
import '../event/random_event_type.dart';
import '../game/game.dart';
import '../game/player.dart';
import 'game_capture.dart';
import 'game_snapshot.dart';

/// The digests of every section of a game at the start of [turn].
typedef TurnDigests = ({int turn, List<String> digests});

/// An executor that records the state of the game it plays: the digests
/// of every section at the start of turn 1 then after each end of turn,
/// what it executed, and on request the whole state at the start of one
/// turn ([dumpTurn]) and the digests after each action of one turn
/// ([traceTurn]).
///
/// It sees an action only when it executes it: in a replay every move of
/// every player, in a live game not those the factions play inside the
/// end of a turn.
class ReferenceRecorder extends GameCapture {
  final TextDigest digest;
  final int? traceTurn;
  final int? dumpTurn;

  final List<TurnDigests> turns = <TurnDigests>[];

  /// Successful actions, the ends of turn included, by type.
  final Map<ActionType, int> actions = <ActionType, int>{};

  /// Random events drawn, for any player, by type.
  final Map<RandomEventType, int> events = <RandomEventType, int>{};

  /// The digests after each action of [traceTurn], in order.
  final List<List<String>> traced = <List<String>>[];

  /// The canonical texts at the start of [dumpTurn], once reached.
  Map<String, String>? dump;

  ReferenceRecorder(this.digest, {this.traceTurn, this.dumpTurn});

  @override
  void onStart(Game game) => _startTurn(game);

  @override
  ActionResult execute(Action action, Game game, Player player) {
    final int turn = game.turn;
    final Map<String, int> seen = _eventsSeen(game);
    final ActionResult result = super.execute(action, game, player);
    if (!result.isSuccess) return result;
    actions[action.type] = (actions[action.type] ?? 0) + 1;
    if (action is EndTurnAction) {
      _countEvents(game, seen);
      _startTurn(game);
    } else if (turn == traceTurn) {
      traced.add(GameSnapshot.digests(game, digest));
    }
    return result;
  }

  void _startTurn(Game game) {
    final Map<String, String> texts = GameSnapshot.texts(game);
    if (game.turn == dumpTurn) dump = texts;
    turns.add((
      turn: game.turn,
      digests: <String>[for (final String text in texts.values) digest(text)],
    ));
  }

  static Map<String, int> _eventsSeen(Game game) => <String, int>{
    for (final Player p in game.players.values) p.id: p.eventState.eventsSeen,
  };

  void _countEvents(Game game, Map<String, int> before) {
    for (final Player p in game.players.values) {
      if (p.eventState.eventsSeen == before[p.id]) continue;
      final RandomEventType drawn = p.eventState.lastDrawn!;
      events[drawn] = (events[drawn] ?? 0) + 1;
    }
  }
}
