import 'package:flutter/widgets.dart';

import '../../../data/game_repository.dart';
import '../../../domain/action/recruit_unit_action.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/game/game.dart';
import '../../../domain/game/game_upgrade_readiness.dart';
import '../../../domain/game/player.dart';
import '../../../domain/unit/unit_cost_calculator.dart';
import '../../../domain/unit/unit_type.dart';
import '../../widgets/army/army_places.dart';
import '../../widgets/army/army_places_view.dart';
import 'game_screen_actions.dart';

/// The army of the human player on its parade ground, counted at each
/// place it serves (« Toutes » for all of them): a green « + » over each
/// type it can recruit now, a squad opening its unit's sheet (counting
/// the place shown) and the barracks opening its building's sheet, as on
/// the base.
Widget armyTab(
  BuildContext context,
  Game game,
  GameRepository repository, {
  required VoidCallback onChanged,
}) {
  final human = game.humanPlayer;
  return ArmyPlacesView(
    buildings: human.buildings,
    places: armyPlacesOf(human),
    recruitable: recruitableUnitsOf(human),
    recruitPlace: RecruitUnitAction.arrivalLevel,
    barracksLocked:
        game.upgradeReadinessesOf(human)[BuildingType.barracks]?.isLocked ??
        false,
    onUnitTap:
        (type, count) =>
            showUnitDetailAction(context, game, type, onChanged, count: count),
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

/// Units of each type [player] has at each place: every level of the map
/// and the kernel's garrison.
ArmyPlaces armyPlacesOf(Player player) => ArmyPlaces({
  for (final MapEntry(key: place, value: units) in player.unitsPerLevel.entries)
    place: {
      for (final MapEntry(key: type, value: unit) in units.entries)
        type: unit.count,
    },
});

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
