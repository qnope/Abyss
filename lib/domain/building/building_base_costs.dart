import '../resource/resource_type.dart';
import 'building_type.dart';

/// Cost of the first level of each building whose upgrades grow by
/// ×1.6 per level (see `exponentialCost`).
const Map<BuildingType, Map<ResourceType, int>> buildingBaseCosts = {
  BuildingType.headquarters: {ResourceType.coral: 60, ResourceType.ore: 40},
  BuildingType.algaeFarm: {ResourceType.coral: 80},
  BuildingType.coralMine: {ResourceType.ore: 60},
  BuildingType.oreExtractor: {ResourceType.coral: 75, ResourceType.energy: 45},
  BuildingType.solarPanel: {ResourceType.coral: 60, ResourceType.ore: 45},
  BuildingType.laboratory: {ResourceType.coral: 75, ResourceType.ore: 60},
  BuildingType.barracks: {
    ResourceType.coral: 60,
    ResourceType.ore: 75,
    ResourceType.energy: 30,
  },
};
