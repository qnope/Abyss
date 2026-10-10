import '../../objective/objective.dart';
import '../game_script.dart';
import '../script_turn.dart';
import 'battle_moves.dart';
import 'conquest_strategy.dart';
import 'event_moves.dart';
import 'tutorial_moves.dart';

/// "Tutoriel": a newcomer who follows the guide of the first chapter to
/// the letter, one objective at a time, then plays like [then].
///
/// It answers the random events and holds an announced raid the way the
/// careful script does, since the guide shows the alert when it comes.
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
    if (turn.player.raidState.isIncoming) turn.defendBase(then.planner);
    turn.followStep(step.id);
  }
}
