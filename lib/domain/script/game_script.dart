import 'script_turn.dart';

/// A way to play a whole game without the UI.
///
/// Each turn, `ScriptRunner` hands the script a [ScriptTurn] to act on
/// through the regular action system, then ends the turn itself.
abstract class GameScript {
  const GameScript();

  /// Name shown in reports.
  String get name;

  /// Plays the current turn. Ending the turn is left to the runner.
  void playTurn(ScriptTurn turn);
}
