import '../resource/resource_type.dart';

Map<ResourceType, int> descentModuleCost() => const {
  ResourceType.coral: 200,
  ResourceType.ore: 150,
  ResourceType.energy: 80,
  ResourceType.pearl: 5,
};

Map<ResourceType, int> pressureCapsuleCost() => const {
  ResourceType.coral: 400,
  ResourceType.ore: 300,
  ResourceType.energy: 150,
  ResourceType.pearl: 15,
};
