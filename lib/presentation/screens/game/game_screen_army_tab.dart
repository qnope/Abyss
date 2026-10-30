import 'package:flutter/widgets.dart';

import '../../../data/game_repository.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/game/game.dart';
import '../../../domain/game/game_upgrade_readiness.dart';
import '../../../domain/game/player.dart';
import '../../../domain/unit/unit_cost_calculator.dart';
import '../../../domain/unit/unit_type.dart';
import '../../widgets/army/army_view.dart';
import 'game_screen_actions.dart';

/// The army of the human player on its parade ground: every unit counted
/// wherever it serves, a green « + » over each type it can recruit now,
/// a squad opening its unit's sheet (counting [currentLevel]) and the
/// barracks opening its building's sheet, as on the base.
Widget armyTab(
  BuildContext context,
  Game game,
  GameRepository repository, {
  required int currentLevel,
  required VoidCallback onChanged,
}) {
  final human = game.humanPlayer;
  return ArmyView(
    buildings: human.buildings,
    counts: armyCountsOf(human),
    recruitable: recruitableUnitsOf(human),
    barracksLocked:
        game.upgradeReadinessesOf(human)[BuildingType.barracks]?.isLocked ??
        false,
    onUnitTap:
        (type) => showUnitDetailAction(
          context,
          game,
          type,
          onChanged,
          level: currentLevel,
        ),
    onBarracksTap:
        (barracks) => showBuildingDetailAction(
          context,
          game,
          repository,
          barracks,
          onChanged,
        ),
  );
}

/// Units of each type [player] has, on every level of the map and in the
/// kernel's garrison; the types with none left out.
Map<UnitType, int> armyCountsOf(Player player) {
  final counts = <UnitType, int>{};
  for (final units in player.unitsPerLevel.values) {
    for (final MapEntry(key: type, value: unit) in units.entries) {
      if (unit.count > 0) counts[type] = (counts[type] ?? 0) + unit.count;
    }
  }
  return counts;
}

/// The unit types [player] can recruit at least one of right now, by the
/// rules of the unit's sheet: unlocked by the barracks, not recruited yet
/// this turn, and paid for at the barracks' price (doubled while it is
/// degraded).
Set<UnitType> recruitableUnitsOf(Player player) {
  final units = UnitCostCalculator();
  final level = player.buildings[BuildingType.barracks]?.level ?? 0;
  final degraded = player.isDegraded(BuildingType.barracks);
  return {
    for (final type in UnitType.values)
      if (units.isUnlocked(type, level) &&
          !player.recruitedUnitTypes.contains(type) &&
          units.maxRecruitableCount(
                type,
                level,
                player.resources,
                degraded: degraded,
              ) >=
              1)
        type,
  };
}
