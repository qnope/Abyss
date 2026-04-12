import '../building/building.dart';
import '../building/building_type.dart';
import '../resource/resource.dart';
import '../resource/resource_type.dart';
import '../tech/tech_branch.dart';
import '../tech/tech_branch_state.dart';
import '../unit/unit.dart';
import '../unit/unit_type.dart';

class PlayerDefaults {
  const PlayerDefaults._();

  static Map<ResourceType, Resource> resources() {
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

  static Map<TechBranch, TechBranchState> techBranches() {
    return {
      TechBranch.military: TechBranchState(branch: TechBranch.military),
      TechBranch.resources: TechBranchState(branch: TechBranch.resources),
      TechBranch.explorer: TechBranchState(branch: TechBranch.explorer),
    };
  }

  static Map<BuildingType, Building> buildings() {
    return {
      BuildingType.headquarters: Building(type: BuildingType.headquarters, level: 0),
      BuildingType.algaeFarm: Building(type: BuildingType.algaeFarm, level: 0),
      BuildingType.coralMine: Building(type: BuildingType.coralMine, level: 0),
      BuildingType.oreExtractor: Building(type: BuildingType.oreExtractor, level: 0),
      BuildingType.solarPanel: Building(type: BuildingType.solarPanel, level: 0),
      BuildingType.laboratory: Building(type: BuildingType.laboratory, level: 0),
      BuildingType.barracks: Building(type: BuildingType.barracks, level: 0),
      BuildingType.coralCitadel: Building(type: BuildingType.coralCitadel, level: 0),
      BuildingType.descentModule: Building(type: BuildingType.descentModule, level: 0),
      BuildingType.pressureCapsule: Building(type: BuildingType.pressureCapsule, level: 0),
      BuildingType.volcanicKernel: Building(type: BuildingType.volcanicKernel, level: 0),
    };
  }

  static Map<int, Map<UnitType, Unit>> unitsPerLevel() {
    return {
      1: {for (final type in UnitType.values) type: Unit(type: type)},
    };
  }
}
