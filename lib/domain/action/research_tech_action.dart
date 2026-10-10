import 'action.dart';
import 'action_failure.dart';
import 'action_result.dart';
import 'action_type.dart';
import '../building/building_type.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../history/history_entry.dart';
import '../tech/tech_branch.dart';
import '../resource/resource_type.dart';
import '../tech/tech_cost_calculator.dart';
import '../tech/tech_option.dart';
import '../tech/tech_tree.dart';

class ResearchTechAction extends Action {
  final TechBranch branch;

  /// Option taken when the next node is a choice; ignored on a tier.
  final TechOption option;

  ResearchTechAction({required this.branch, this.option = TechOption.a});

  @override
  ActionType get type => ActionType.researchTech;

  @override
  String get description => 'Rechercher tech $branch';

  @override
  ActionResult validate(Game game, Player player) {
    final state = player.techBranches[branch];
    if (state == null) {
      return ActionResult.failure(ActionFailure.branchNotFound);
    }
    if (!state.unlocked) {
      return ActionResult.failure(ActionFailure.branchLocked);
    }
    if (!player.worksite.canResearch) {
      return ActionResult.failure(ActionFailure.researchAlreadyStarted);
    }
    final targetLevel = state.researchLevel + 1;
    if (targetLevel > TechCostCalculator.maxResearchLevel) {
      return ActionResult.failure(ActionFailure.maxLevelReached);
    }
    final labLevel = player.buildings[BuildingType.laboratory]?.level ?? 0;
    if (labLevel < TechCostCalculator.requiredLabLevel(targetLevel)) {
      return ActionResult.failure(ActionFailure.laboratoryLevelTooLow);
    }
    final costs = _costs(player, targetLevel);
    for (final entry in costs.entries) {
      final available = player.resources[entry.key]?.amount ?? 0;
      if (available < entry.value) {
        return ActionResult.failure(ActionFailure.notEnoughResources);
      }
    }
    return ActionResult.success();
  }

  @override
  ActionResult execute(Game game, Player player) {
    final validation = validate(game, player);
    if (!validation.isSuccess) return validation;
    final targetLevel = player.techBranches[branch]!.researchLevel + 1;
    final costs = _costs(player, targetLevel);
    for (final entry in costs.entries) {
      player.resources[entry.key]!.amount -= entry.value;
    }
    final state = player.techBranches[branch]!;
    if (TechTree.isChoiceLevel(targetLevel)) state.choose(targetLevel, option);
    state.researchLevel = targetLevel;
    player.worksite.research++;
    return ActionResult.success();
  }

  Map<ResourceType, int> _costs(Player player, int level) =>
      TechCostCalculator.researchCost(branch, level,
          opened: TechCostCalculator.openedBranches(player.techBranches));

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
