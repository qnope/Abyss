import 'building_type.dart';
import '../resource/resource_type.dart';

Map<ResourceType, int> coralCitadelCost(int currentLevel) {
  const table = {
    0: [120, 120, 60, 5],
    1: [240, 240, 120, 10],
    2: [500, 500, 250, 20],
    3: [850, 850, 425, 35],
    4: [1300, 1300, 650, 60],
  };
  final row = table[currentLevel];
  if (row == null) return {};
  return {
    ResourceType.coral: row[0],
    ResourceType.ore: row[1],
    ResourceType.energy: row[2],
    ResourceType.pearl: row[3],
  };
}

Map<BuildingType, int> coralCitadelPrereqs(int targetLevel) {
  final hqLevel = switch (targetLevel) {
    1 => 3,
    2 => 5,
    3 => 7,
    4 => 9,
    5 => 10,
    _ => 0,
  };
  return hqLevel > 0 ? {BuildingType.headquarters: hqLevel} : {};
}
