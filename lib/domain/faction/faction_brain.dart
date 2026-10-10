import '../action/recruit_unit_action.dart';
import '../map/grid_position.dart';
import '../script/game_script.dart';
import '../script/script_turn.dart';
import '../script/strategies/balanced_strategy.dart';
import '../script/strategies/explore_moves.dart';
import '../unit/unit_type.dart';
import 'faction_personality.dart';

/// What a faction plays for now: a balanced economy that also scouts the
/// level 1 and picks up what it finds. It never attacks anybody.
///
/// Every personality shares it until its own brain exists; it only uses
/// the actions of the game, with their costs and checks.
class FactionBrain extends GameScript {
  static const BalancedStrategy _economy = BalancedStrategy();

  final FactionPersonality personality;

  const FactionBrain(this.personality);

  @override
  String get name => 'faction-${personality.name}';

  @override
  void playTurn(ScriptTurn turn) {
    turn.collectRevealed(1);
    final bool hasScout =
        (turn.player.unitsOnLevel(1)[UnitType.scout]?.count ?? 0) > 0;
    if (!hasScout && !turn.fullyExplored(1)) {
      turn.tryPerform(RecruitUnitAction(unitType: UnitType.scout, quantity: 1));
    }
    turn.explore(1, 1, (GridPosition _) => 0);
    _economy.playTurn(turn);
  }
}
