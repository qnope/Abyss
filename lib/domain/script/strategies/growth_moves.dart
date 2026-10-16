import '../../action/action.dart';
import '../../action/action_failure.dart';
import '../../action/research_tech_action.dart';
import '../../action/unlock_branch_action.dart';
import '../../action/upgrade_building_action.dart';
import '../../building/building_type.dart';
import '../../resource/consumption_calculator.dart';
import '../../resource/production_calculator.dart';
import '../../resource/resource_type.dart';
import '../../tech/tech_branch.dart';
import '../../tech/tech_option.dart';
import '../../tech/tech_tree.dart';
import '../../turn/turn_production.dart';
import '../script_turn.dart';

/// Growth moves of a player who watches the energy balance and follows a
/// research plan.
extension GrowthMoves on ScriptTurn {
  /// Research plan: production first, then the army, one node at a time.
  static const List<TechBranch> researchPlan = <TechBranch>[
    TechBranch.resources,
    TechBranch.military,
    TechBranch.resources,
    TechBranch.military,
    TechBranch.military,
    TechBranch.resources,
    TechBranch.military,
    TechBranch.resources,
    TechBranch.military,
    TechBranch.resources,
  ];

  /// Unlocks and researches the next nodes of [plan] it can pay, with the
  /// options of [picks]. An Explorer node it cannot pay is passed over
  /// for the next entry; any other shortfall waits for a later turn.
  void research({
    List<TechBranch> plan = researchPlan,
    Map<TechBranch, List<TechOption>> picks = GrowthMoves.picks,
  }) {
    final Map<TechBranch, int> planned = <TechBranch, int>{};
    for (final TechBranch branch in plan) {
      final int target = (planned[branch] ?? 0) + 1;
      planned[branch] = target;
      final state = player.techBranches[branch]!;
      if (state.researchLevel >= target) continue;
      if (!state.unlocked) {
        final Action unlock = UnlockBranchAction(branch: branch);
        if (!tryPerform(unlock)) {
          if (_passesOver(branch, unlock)) continue;
          return;
        }
      }
      final Action next = researchNext(branch, picks: picks);
      if (!tryPerform(next) && !_passesOver(branch, next)) return;
    }
  }

  /// Whether the plan goes on past [step] of [branch]: only an Explorer
  /// node short of resources is passed over.
  bool _passesOver(TechBranch branch, Action step) =>
      branch == TechBranch.explorer &&
      !isOver &&
      step.validate(game, player).reason == ActionFailure.notEnoughResources;

  /// Options a defensive player takes at the choice nodes 2 and 4.
  static const Map<TechBranch, List<TechOption>> picks = {
    TechBranch.military: [TechOption.b, TechOption.a],
    TechBranch.resources: [TechOption.a, TechOption.a],
    TechBranch.explorer: [TechOption.b, TechOption.b],
  };

  /// Research of the next node of [branch], with the option of [picks].
  ResearchTechAction researchNext(
    TechBranch branch, {
    Map<TechBranch, List<TechOption>> picks = GrowthMoves.picks,
  }) {
    final int level = player.techBranches[branch]!.researchLevel + 1;
    final TechOption option = TechTree.isChoiceLevel(level)
        ? picks[branch]![TechTree.choiceIndex(level)]
        : TechOption.a;
    return ResearchTechAction(branch: branch, option: option);
  }

  /// Energy produced minus energy the buildings and the heating of the
  /// farms use this turn.
  int get energyMargin {
    final int produced = ProductionCalculator.fromBuildings(player.buildings,
            techBranches: player.techBranches)[ResourceType.energy] ??
        0;
    return produced -
        TurnProduction.energyConsumption(player, turn: game.turn);
  }

  /// Raises the buildings of [order] one level at a time, round after
  /// round, skipping any upgrade that would leave the base short of
  /// energy (Solar Panels first in that case).
  void growInOrder(List<BuildingType> order) {
    bool progressed = true;
    while (progressed && !isOver) {
      progressed = false;
      for (final BuildingType type in order) {
        final int level = player.buildings[type]!.level;
        final int extra =
            ConsumptionCalculator.buildingEnergyConsumption(type, level + 1) -
                ConsumptionCalculator.buildingEnergyConsumption(type, level);
        final int stock = player.resources[ResourceType.energy]!.amount;
        if (type != BuildingType.solarPanel &&
            energyMargin - extra + stock ~/ 10 < 0) {
          if (tryPerform(
              UpgradeBuildingAction(buildingType: BuildingType.solarPanel))) {
            progressed = true;
          }
          continue;
        }
        if (tryPerform(UpgradeBuildingAction(buildingType: type))) {
          progressed = true;
        }
      }
    }
  }
}
