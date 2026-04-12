import '../resource/resource_type.dart';

Map<ResourceType, int> volcanicKernelCost(int currentLevel) {
  final scale = currentLevel * currentLevel + 1;
  return {
    ResourceType.coral: 50 * scale,
    ResourceType.ore: 40 * scale,
    ResourceType.energy: 30 * scale,
    ResourceType.pearl: 5 + 3 * (currentLevel + 1),
  };
}
