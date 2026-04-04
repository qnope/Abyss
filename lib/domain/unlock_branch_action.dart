import 'action.dart';
import 'action_result.dart';
import 'action_type.dart';
import 'building_type.dart';
import 'game.dart';
import 'tech_branch.dart';
import 'tech_cost_calculator.dart';

class UnlockBranchAction extends Action {
  final TechBranch branch;

  UnlockBranchAction({required this.branch});

  @override
  ActionType get type => ActionType.unlockBranch;

  @override
  String get description => 'Debloquer branche $branch';

  @override
  ActionResult validate(Game game) {
    final state = game.techBranches[branch];
    if (state == null) {
      return ActionResult.failure('Branche introuvable');
    }
    if (state.unlocked) {
      return ActionResult.failure('Branche deja debloquee');
    }
    final labLevel = game.buildings[BuildingType.laboratory]?.level ?? 0;
    if (labLevel < 1) {
      return ActionResult.failure('Laboratoire requis');
    }
    final costs = TechCostCalculator.unlockCost(branch);
    for (final entry in costs.entries) {
      final available = game.resources[entry.key]?.amount ?? 0;
      if (available < entry.value) {
        return ActionResult.failure('Ressources insuffisantes');
      }
    }
    return ActionResult.success();
  }

  @override
  ActionResult execute(Game game) {
    final validation = validate(game);
    if (!validation.isSuccess) return validation;
    final costs = TechCostCalculator.unlockCost(branch);
    for (final entry in costs.entries) {
      game.resources[entry.key]!.amount -= entry.value;
    }
    game.techBranches[branch]!.unlocked = true;
    return ActionResult.success();
  }
}
