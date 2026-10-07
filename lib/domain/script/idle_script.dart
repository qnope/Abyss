import 'game_script.dart';
import 'script_turn.dart';

/// Ends every turn without acting: the baseline every strategy should beat.
class IdleScript extends GameScript {
  const IdleScript();

  @override
  String get name => 'idle';

  @override
  void playTurn(ScriptTurn turn) {}
}
