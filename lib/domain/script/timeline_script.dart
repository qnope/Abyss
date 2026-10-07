import 'action_spec.dart';
import 'game_script.dart';
import 'script_turn.dart';

/// A scenario written in advance: the actions to play on given turns.
///
/// Turns the timeline leaves out are handed to [otherwise] when set, so a
/// scenario can force a few moves and let a strategy play the rest.
class TimelineScript extends GameScript {
  @override
  final String name;

  final Map<int, List<ActionSpec>> turns;
  final GameScript? otherwise;

  const TimelineScript({
    required this.name,
    required this.turns,
    this.otherwise,
  });

  @override
  void playTurn(ScriptTurn turn) {
    final List<ActionSpec>? planned = turns[turn.number];
    if (planned == null) {
      otherwise?.playTurn(turn);
      return;
    }
    for (final ActionSpec spec in planned) {
      turn.perform(spec(turn.random));
    }
  }
}
