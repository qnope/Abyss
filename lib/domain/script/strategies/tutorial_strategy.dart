import '../../objective/objective.dart';
import '../game_script.dart';
import '../script_turn.dart';
import 'conquest_strategy.dart';
import 'event_moves.dart';
import 'tutorial_moves.dart';

/// "Tutoriel": a newcomer who follows the guide of the first chapter to
/// the letter, one objective at a time, then plays like [then].
///
/// It answers the random events and, once the step of the turn is played,
/// recruits the Harpoonists the guide advises against the first raid.
/// Once the first chapter is done or the first raid fought, [then] plays
/// the rest of the game.
class TutorialStrategy extends GameScript {
  final ConquestStrategy then;

  const TutorialStrategy({this.then = const ConquestStrategy()});

  @override
  String get name => 'tutorial';

  @override
  void playTurn(ScriptTurn turn) {
    final Objective? step = turn.tutorialStep;
    if (step == null) return then.playTurn(turn);
    turn.playEvents(then.planner);
    turn.followStep(step.id);
    if (turn.player.raidState.isIncoming) {
      turn.followRaidAdvice(then.planner);
    }
  }
}
