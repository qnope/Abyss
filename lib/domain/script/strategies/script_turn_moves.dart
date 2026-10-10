import '../../action/recruit_unit_action.dart';
import '../../action/upgrade_building_action.dart';
import '../../building/building_type.dart';
import '../../unit/unit_cost_calculator.dart';
import '../../unit/unit_type.dart';
import '../script_turn.dart';

/// Common moves the built-in strategies are made of.
extension ScriptTurnMoves on ScriptTurn {
  /// Raises the buildings of [order] one level at a time, round after
  /// round, until none of them can go up anymore.
  void upgradeInOrder(List<BuildingType> order) {
    bool progressed = true;
    while (progressed && !isOver) {
      progressed = false;
      for (final BuildingType type in order) {
        if (tryPerform(UpgradeBuildingAction(buildingType: type))) {
          progressed = true;
        }
      }
    }
  }

  /// Recruits [share] (0 to 1) of the most [type] units affordable now;
  /// returns how many joined.
  int recruitShare(UnitType type, double share) {
    final int barracks = player.buildings[BuildingType.barracks]?.level ?? 0;
    final int affordable = UnitCostCalculator()
        .maxRecruitableCount(
      type,
      barracks,
      player.resources,
      degraded: player.isDegraded(BuildingType.barracks),
    );
    final int count = (affordable * share).floor();
    if (count <= 0) return 0;
    final RecruitUnitAction action =
        RecruitUnitAction(unitType: type, quantity: count);
    return tryPerform(action) ? count : 0;
  }

  /// Best defender the barracks can train, or `null` before it is built.
  UnitType? get bestDefender {
    final int barracks = player.buildings[BuildingType.barracks]?.level ?? 0;
    final UnitCostCalculator costs = UnitCostCalculator();
    if (costs.isUnlocked(UnitType.guardian, barracks)) return UnitType.guardian;
    if (costs.isUnlocked(UnitType.harpoonist, barracks)) {
      return UnitType.harpoonist;
    }
    return null;
  }
}
