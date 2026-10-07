import '../../building/building_type.dart';
import '../../unit/unit_type.dart';
import '../game_script.dart';
import '../script_turn.dart';
import 'economy_strategy.dart';
import 'script_turn_moves.dart';

/// "Équilibrée": spends part of each turn on defence (barracks, Coral
/// Citadel, recruits) and the rest on production. Raids should not end it.
class BalancedStrategy extends GameScript {
  static const List<BuildingType> buildOrder = <BuildingType>[
    ...EconomyStrategy.buildOrder,
    BuildingType.barracks,
    BuildingType.coralCitadel,
  ];

  /// Share of the affordable defenders recruited on a quiet turn.
  final double peaceRecruitShare;

  /// Share recruited while a raid is announced.
  final double alertRecruitShare;

  const BalancedStrategy({
    this.peaceRecruitShare = 0.25,
    this.alertRecruitShare = 0.8,
  });

  @override
  String get name => 'balanced';

  @override
  void playTurn(ScriptTurn turn) {
    final UnitType? defender = turn.bestDefender;
    if (defender != null) {
      final bool alert = turn.player.raidState.isIncoming;
      turn.recruitShare(
        defender,
        alert ? alertRecruitShare : peaceRecruitShare,
      );
    }
    turn.upgradeInOrder(buildOrder);
  }
}
