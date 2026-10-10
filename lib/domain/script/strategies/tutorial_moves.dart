import '../../action/recruit_unit_action.dart';
import '../../action/upgrade_building_action.dart';
import '../../building/building_type.dart';
import '../../objective/installation_objectives.dart';
import '../../objective/objective.dart';
import '../../objective/objective_id.dart';
import '../../objective/objective_migration.dart';
import '../../raid/raid_state.dart';
import '../../unit/unit_type.dart';
import '../script_turn.dart';
import 'explore_moves.dart';
import 'growth_moves.dart';

/// What a newcomer does when the guide of the first chapter gives one
/// objective at a time: exactly what it asks, nothing more.
extension TutorialMoves on ScriptTurn {
  /// Scouts the guide asks for in its sixth objective.
  static const int tutorialScouts = 2;

  /// The objective of the first chapter the guide gives now: the first
  /// one not completed, `null` once all are or once a raid was fought.
  Objective? get tutorialStep {
    final RaidState raids = player.raidState;
    if (raids.raidsRepelled + raids.raidsLost > 0) return null;
    final state = ObjectiveMigration.stateOf(game, player);
    for (final Objective objective in installationObjectives) {
      if (!state.isCompleted(objective.id)) return objective;
    }
    return null;
  }

  /// Plays what objective [id] of the first chapter asks for. The last
  /// one, the first raid, only waits for the raid.
  void followStep(ObjectiveId id) {
    switch (id) {
      case ObjectiveId.hqLevel1:
        _raise(BuildingType.headquarters, 1);
      case ObjectiveId.algaeFarm:
        _raise(BuildingType.algaeFarm, 1);
      case ObjectiveId.mines:
        _raise(BuildingType.coralMine, 1);
        _raise(BuildingType.oreExtractor, 1);
      case ObjectiveId.solarPanel:
        _raise(BuildingType.solarPanel, 1);
      case ObjectiveId.hqLevel2:
        _raise(BuildingType.headquarters, 2);
      case ObjectiveId.barracksAndScouts:
        _raise(BuildingType.barracks, 1);
        _recruitScouts();
      case ObjectiveId.explore:
        explore(1, 1, (_) => 0);
      case ObjectiveId.laboratoryAndResearch:
        _raise(BuildingType.laboratory, 1);
        research();
      default:
        break;
    }
  }

  /// Upgrades [type] while it is under [level].
  void _raise(BuildingType type, int level) {
    if (player.buildings[type]!.level >= level) return;
    tryPerform(UpgradeBuildingAction(buildingType: type));
  }

  void _recruitScouts() {
    final int scouts = player.unitsOnLevel(1)[UnitType.scout]!.count;
    if (scouts >= tutorialScouts) return;
    tryPerform(RecruitUnitAction(
        unitType: UnitType.scout, quantity: tutorialScouts - scouts));
  }
}
