import 'package:hive/hive.dart';
import 'building.dart';
import 'building_type.dart';
import 'player.dart';
import 'resource.dart';
import 'resource_type.dart';

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

  Game({
    required this.player,
    this.turn = 1,
    DateTime? createdAt,
    Map<ResourceType, Resource>? resources,
    Map<BuildingType, Building>? buildings,
  })  : createdAt = createdAt ?? DateTime.now(),
        resources = resources ?? defaultResources(),
        buildings = buildings ?? defaultBuildings();

  static Map<ResourceType, Resource> defaultResources() {
    return {
      ResourceType.algae: Resource(
        type: ResourceType.algae,
        amount: 100,
        productionPerTurn: 10,
        maxStorage: 500,
      ),
      ResourceType.coral: Resource(
        type: ResourceType.coral,
        amount: 80,
        productionPerTurn: 8,
        maxStorage: 500,
      ),
      ResourceType.ore: Resource(
        type: ResourceType.ore,
        amount: 50,
        productionPerTurn: 5,
        maxStorage: 500,
      ),
      ResourceType.energy: Resource(
        type: ResourceType.energy,
        amount: 60,
        productionPerTurn: 6,
        maxStorage: 500,
      ),
      ResourceType.pearl: Resource(
        type: ResourceType.pearl,
        amount: 5,
        productionPerTurn: 0,
        maxStorage: 100,
      ),
    };
  }

  static Map<BuildingType, Building> defaultBuildings() {
    return {
      BuildingType.headquarters: Building(type: BuildingType.headquarters, level: 0),
      BuildingType.algaeFarm: Building(type: BuildingType.algaeFarm, level: 0),
      BuildingType.coralMine: Building(type: BuildingType.coralMine, level: 0),
      BuildingType.oreExtractor: Building(type: BuildingType.oreExtractor, level: 0),
      BuildingType.solarPanel: Building(type: BuildingType.solarPanel, level: 0),
    };
  }
}
