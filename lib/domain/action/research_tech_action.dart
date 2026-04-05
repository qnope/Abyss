import 'action.dart';
import 'action_result.dart';
import 'action_type.dart';
import '../building/building_type.dart';
import '../game/game.dart';
import '../tech/tech_branch.dart';
import '../tech/tech_cost_calculator.dart';

class ResearchTechAction extends Action {
  final TechBranch branch;

  ResearchTechAction({required this.branch});

  @override
  ActionType get type => ActionType.researchTech;

  @override
  String get description => 'Rechercher tech $branch';

  @override
  ActionResult validate(Game game) {
    final state = game.techBranches[branch];
    if (state == null) {
      return ActionResult.failure('Branche introuvable');
    }
    if (!state.unlocked) {
      return ActionResult.failure('Branche verrouillee');
    }
    final targetLevel = state.researchLevel + 1;
    if (targetLevel > TechCostCalculator.maxResearchLevel) {
      return ActionResult.failure('Niveau maximum atteint');
    }
    final labLevel = game.buildings[BuildingType.laboratory]?.level ?? 0;
    if (labLevel < TechCostCalculator.requiredLabLevel(targetLevel)) {
      return ActionResult.failure('Niveau de laboratoire insuffisant');
    }
    final costs = TechCostCalculator.researchCost(branch, targetLevel);
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
    final targetLevel = game.techBranches[branch]!.researchLevel + 1;
    final costs = TechCostCalculator.researchCost(branch, targetLevel);
    for (final entry in costs.entries) {
      game.resources[entry.key]!.amount -= entry.value;
    }
    game.techBranches[branch]!.researchLevel = targetLevel;
    return ActionResult.success();
  }
}
