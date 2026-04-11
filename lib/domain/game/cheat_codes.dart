import '../building/building_type.dart';
import '../tech/tech_branch.dart';
import '../unit/unit_type.dart';
import 'player.dart';

class CheatCodes {
  const CheatCodes._();

  static void apply(Player player) {
    if (player.name != 'qnope') return;
    _boostResources(player);
    _boostBuildings(player);
    _boostTech(player);
    _boostUnits(player);
  }

  static void _boostResources(Player player) {
    for (final resource in player.resources.values) {
      resource.amount = 5000;
    }
  }

  static void _boostBuildings(Player player) {
    final levels = {
      BuildingType.headquarters: 7,
      BuildingType.algaeFarm: 3,
      BuildingType.coralMine: 3,
      BuildingType.oreExtractor: 3,
      BuildingType.solarPanel: 3,
      BuildingType.laboratory: 3,
      BuildingType.barracks: 3,
    };
    for (final entry in levels.entries) {
      player.buildings[entry.key]?.level = entry.value;
    }
  }

  static void _boostTech(Player player) {
    for (final branch in TechBranch.values) {
      final state = player.techBranches[branch];
      if (state == null) continue;
      state.unlocked = true;
      state.researchLevel = 3;
    }
  }

  static void _boostUnits(Player player) {
    final units = player.unitsOnLevel(1);
    units[UnitType.scout]?.count = 200;
    units[UnitType.harpoonist]?.count = 200;
    units[UnitType.abyssAdmiral]?.count = 10;
  }
}
