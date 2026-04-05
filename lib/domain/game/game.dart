import 'package:hive/hive.dart';
import '../building/building.dart';
import '../building/building_type.dart';
import '../map/game_map.dart';
import 'player.dart';
import '../resource/resource.dart';
import '../resource/resource_type.dart';
import '../tech/tech_branch.dart';
import '../tech/tech_branch_state.dart';
import '../unit/unit.dart';
import '../unit/unit_type.dart';

part 'game.g.dart';

@HiveType(typeId: 1)
class Game extends HiveObject {
  @HiveField(0)
  final Player player;

  @HiveField(1)
  int turn;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final Map<ResourceType, Resource> resources;

  @HiveField(4)
  final Map<BuildingType, Building> buildings;

  @HiveField(5)
  final Map<TechBranch, TechBranchState> techBranches;

  @HiveField(6)
  final Map<UnitType, Unit> units;

  @HiveField(7)
  final List<UnitType> recruitedUnitTypes;

  @HiveField(8)
  GameMap? gameMap;

  Game({
    required this.player,
    this.turn = 1,
    DateTime? createdAt,
    Map<ResourceType, Resource>? resources,
    Map<BuildingType, Building>? buildings,
    Map<TechBranch, TechBranchState>? techBranches,
    Map<UnitType, Unit>? units,
    List<UnitType>? recruitedUnitTypes,
    this.gameMap,
  })  : createdAt = createdAt ?? DateTime.now(),
        resources = resources ?? defaultResources(),
        buildings = buildings ?? defaultBuildings(),
        techBranches = techBranches ?? defaultTechBranches(),
        units = units ?? defaultUnits(),
        recruitedUnitTypes = recruitedUnitTypes ?? [];

  static Map<ResourceType, Resource> defaultResources() {
    return {
      ResourceType.algae: Resource(
        type: ResourceType.algae,
        amount: 100,
        maxStorage: 5000,
      ),
      ResourceType.coral: Resource(
        type: ResourceType.coral,
        amount: 80,
        maxStorage: 5000,
      ),
      ResourceType.ore: Resource(
        type: ResourceType.ore,
        amount: 50,
        maxStorage: 5000,
      ),
      ResourceType.energy: Resource(
        type: ResourceType.energy,
        amount: 60,
        maxStorage: 1000,
      ),
      ResourceType.pearl: Resource(
        type: ResourceType.pearl,
        amount: 5,
        maxStorage: 100,
      ),
    };
  }

  static Map<TechBranch, TechBranchState> defaultTechBranches() {
    return {
      TechBranch.military: TechBranchState(branch: TechBranch.military),
      TechBranch.resources: TechBranchState(branch: TechBranch.resources),
      TechBranch.explorer: TechBranchState(branch: TechBranch.explorer),
    };
  }

  static Map<BuildingType, Building> defaultBuildings() {
    return {
      BuildingType.headquarters: Building(type: BuildingType.headquarters, level: 0),
      BuildingType.algaeFarm: Building(type: BuildingType.algaeFarm, level: 0),
      BuildingType.coralMine: Building(type: BuildingType.coralMine, level: 0),
      BuildingType.oreExtractor: Building(type: BuildingType.oreExtractor, level: 0),
      BuildingType.solarPanel: Building(type: BuildingType.solarPanel, level: 0),
      BuildingType.laboratory: Building(type: BuildingType.laboratory, level: 0),
      BuildingType.barracks: Building(type: BuildingType.barracks, level: 0),
    };
  }

  static Map<UnitType, Unit> defaultUnits() {
    return {
      for (final type in UnitType.values) type: Unit(type: type),
    };
  }
}
