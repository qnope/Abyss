import '../../action/unlock_branch_action.dart';
import '../../building/building_type.dart';
import '../../tech/tech_branch.dart';
import '../../unit/unit_type.dart';
import '../game_script.dart';
import '../script_turn.dart';
import 'economy_strategy.dart';
import 'growth_moves.dart';
import 'script_turn_moves.dart';

/// "Équilibrée": spends part of each turn on defence (barracks, Coral
/// Citadel, Military research, recruits) and the rest on production.
/// Raids should not end it.
///
/// Defenders come as one Gardien for every Harponneur and a half: Gardiens
/// alone barely scratch level 3 monsters.
class BalancedStrategy extends GameScript {
  static const List<BuildingType> buildOrder = <BuildingType>[
    ...EconomyStrategy.buildOrder,
    BuildingType.barracks,
    BuildingType.coralCitadel,
    BuildingType.laboratory,
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
    final bool alert = turn.player.raidState.isIncoming;
    final double share = alert ? alertRecruitShare : peaceRecruitShare;
    if (turn.bestDefender == UnitType.guardian) {
      turn.recruitShare(UnitType.guardian, share / 3);
      turn.recruitShare(UnitType.harpoonist, share / 2);
    } else if (turn.bestDefender != null) {
      turn.recruitShare(UnitType.harpoonist, share);
    }
    turn.tryPerform(UnlockBranchAction(branch: TechBranch.military));
    turn.tryPerform(turn.researchNext(TechBranch.military));
    turn.upgradeInOrder(buildOrder);
  }
}
