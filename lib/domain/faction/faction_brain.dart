import '../script/game_script.dart';
import '../script/script_turn.dart';
import '../script/strategies/conquest_strategy.dart';
import 'faction_kernel_guard.dart';
import 'faction_personality.dart';
import 'faction_traits.dart';
import 'faction_war.dart';
import 'faction_war_recruit.dart';

/// What a faction plays: the whole game of a careful player, from the
/// first building to the volcanic kernel at level 10 ([ConquestStrategy]),
/// and now and then an attack on the weakest base or post it knows
/// ([FactionWar]).
///
/// The traits of the personality bend it ([FactionTraits]); it only uses
/// the actions of the game, with their costs and checks.
class FactionBrain extends GameScript {
  final FactionPersonality personality;

  const FactionBrain(this.personality);

  @override
  String get name => 'faction-${personality.name}';

  @override
  void playTurn(ScriptTurn turn) {
    final FactionTraits traits = FactionTraits.of(personality);
    FactionWar.play(turn, personality);
    ConquestStrategy(
      name: 'faction',
      conquestShare: traits.conquestShare,
      defends: traits.defends,
      contests: false,
      chasesWrecks: true,
      growth: traits.growth,
      explorers: traits.explorers,
    ).playTurn(turn);
    FactionWarRecruit.play(turn, traits);
    FactionKernelGuard.play(turn, traits.guardShare);
  }
}
