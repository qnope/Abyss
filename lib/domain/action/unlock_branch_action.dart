import 'action.dart';
import 'action_result.dart';
import 'action_type.dart';
import '../building/building_type.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../tech/tech_branch.dart';
import '../tech/tech_cost_calculator.dart';

class UnlockBranchAction extends Action {
  final TechBranch branch;

  UnlockBranchAction({required this.branch});

  @override
  ActionType get type => ActionType.unlockBranch;

  @override
  String get description => 'Debloquer branche $branch';

  @override
  ActionResult validate(Game game, Player player) {
    final state = player.techBranches[branch];
    if (state == null) {
      return ActionResult.failure('Branche introuvable');
    }
    if (state.unlocked) {
      return ActionResult.failure('Branche deja debloquee');
    }
    final labLevel = player.buildings[BuildingType.laboratory]?.level ?? 0;
    if (labLevel < 1) {
      return ActionResult.failure('Laboratoire requis');
    }
    final costs = TechCostCalculator.unlockCost(branch);
    for (final entry in costs.entries) {
      final available = player.resources[entry.key]?.amount ?? 0;
      if (available < entry.value) {
        return ActionResult.failure('Ressources insuffisantes');
      }
    }
    return ActionResult.success();
  }

  @override
  ActionResult execute(Game game, Player player) {
    final validation = validate(game, player);
    if (!validation.isSuccess) return validation;
    final costs = TechCostCalculator.unlockCost(branch);
    for (final entry in costs.entries) {
      player.resources[entry.key]!.amount -= entry.value;
    }
    player.techBranches[branch]!.unlocked = true;
    return ActionResult.success();
  }
}
