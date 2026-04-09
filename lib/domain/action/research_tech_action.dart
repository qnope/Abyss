import 'action.dart';
import 'action_result.dart';
import 'action_type.dart';
import '../building/building_type.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../history/history_entry.dart';
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
  ActionResult validate(Game game, Player player) {
    final state = player.techBranches[branch];
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
    final labLevel = player.buildings[BuildingType.laboratory]?.level ?? 0;
    if (labLevel < TechCostCalculator.requiredLabLevel(targetLevel)) {
      return ActionResult.failure('Niveau de laboratoire insuffisant');
    }
    final costs = TechCostCalculator.researchCost(branch, targetLevel);
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
    final targetLevel = player.techBranches[branch]!.researchLevel + 1;
    final costs = TechCostCalculator.researchCost(branch, targetLevel);
    for (final entry in costs.entries) {
      player.resources[entry.key]!.amount -= entry.value;
    }
    player.techBranches[branch]!.researchLevel = targetLevel;
    return ActionResult.success();
  }

  @override
  HistoryEntry? makeHistoryEntry(
    Game game,
    Player player,
    ActionResult result,
    int turn,
  ) {
    return ResearchEntry(
      turn: turn,
      branch: branch,
      isUnlock: false,
      newLevel: player.techBranches[branch]!.researchLevel,
    );
  }
}
