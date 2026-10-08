import 'building_type.dart';
import '../resource/exponential_cost.dart';
import '../resource/resource_type.dart';

const _citadelBaseCost = {
  ResourceType.coral: 250,
  ResourceType.ore: 250,
  ResourceType.energy: 125,
};
const _citadelPearls = [5, 10, 20, 35, 60];

Map<ResourceType, int> coralCitadelCost(int currentLevel) {
  if (currentLevel < 0 || currentLevel >= _citadelPearls.length) return {};
  return {
    ...exponentialCost(_citadelBaseCost, currentLevel),
    ResourceType.pearl: _citadelPearls[currentLevel],
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
