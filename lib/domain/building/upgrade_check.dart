import '../resource/resource_type.dart';
import 'building_type.dart';

class UpgradeCheck {
  final bool canUpgrade;
  final bool isMaxLevel;
  final Map<ResourceType, int> missingResources;
  final Map<BuildingType, int> missingPrerequisites;

  const UpgradeCheck({
    required this.canUpgrade,
    this.isMaxLevel = false,
    this.missingResources = const {},
    this.missingPrerequisites = const {},
  });
}
