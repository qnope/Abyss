import '../building/building.dart';
import '../building/building_deactivator.dart';
import '../building/building_type.dart';
import '../event/event_production.dart';
import '../game/difficulty.dart';
import '../game/player.dart';
import '../resource/consumption_calculator.dart';
import '../resource/production_calculator.dart';
import '../resource/resource_type.dart';

/// What a player's base makes and spends at the end of a turn, for the end
/// of turn itself and for every prediction of it.
abstract final class TurnProduction {
  /// What the buildings make at the end of [turn], [deactivated] ones
  /// apart: scaled by [difficulty], then changed by the random event
  /// lasting during [turn]; a faction ([isFaction]) by the difficulty's
  /// faction percent. The pearl income comes on top.
  static Map<ResourceType, int> of(
    Player player, {
    required int turn,
    required Difficulty difficulty,
    Iterable<BuildingType> deactivated = const [],
    bool isFaction = false,
  }) {
    final Map<BuildingType, Building> buildings = Map.of(player.buildings);
    for (final BuildingType type in deactivated) {
      buildings[type] = Building(type: type, level: 0);
    }
    return EventProduction.adjust(
      difficulty.scaleProduction(
        ProductionCalculator.fromBuildings(
          buildings,
          techBranches: player.techBranches,
        ),
        faction: isFaction,
      ),
      player.eventState,
      turn,
    );
  }

  /// Energy spent at the end of [turn]: the buildings still running, plus
  /// the heating of a cold current.
  static int energyConsumption(
    Player player, {
    required int turn,
    Iterable<BuildingType> deactivated = const [],
  }) =>
      ConsumptionCalculator.totalBuildingConsumption(
        player.buildings,
        excluded: deactivated.toSet(),
      ) +
      EventProduction.heatingEnergy(player.eventState, turn);

  /// Buildings shut down at the end of [turn] for lack of energy, given
  /// the [production] of the turn. The heating is paid first.
  static List<BuildingType> deactivated(
    Player player,
    Map<ResourceType, int> production, {
    required int turn,
  }) => BuildingDeactivator.deactivate(
    buildings: player.buildings,
    energyProduction:
        (production[ResourceType.energy] ?? 0) -
        EventProduction.heatingEnergy(player.eventState, turn),
    energyStock: player.resources[ResourceType.energy]?.amount ?? 0,
  );
}
