import '../script/game_script.dart';
import '../script/script_turn.dart';
import '../script/strategies/conquest_strategy.dart';
import 'faction_kernel_guard.dart';
import 'faction_personality.dart';
import 'faction_war.dart';

/// What a faction plays: the whole game of a careful player, from the
/// first building to the volcanic kernel at level 10 ([ConquestStrategy]),
/// and now and then an attack on the weakest base or post it knows
/// ([FactionWar]).
///
/// Every personality shares it until its own brain exists; it only uses
/// the actions of the game, with their costs and checks.
class FactionBrain extends GameScript {
  static const ConquestStrategy _conquest = ConquestStrategy(name: 'faction');

  final FactionPersonality personality;

  const FactionBrain(this.personality);

  @override
  String get name => 'faction-${personality.name}';

  @override
  void playTurn(ScriptTurn turn) {
    FactionWar.play(turn, personality);
    _conquest.playTurn(turn);
    FactionKernelGuard.play(turn);
  }
}
