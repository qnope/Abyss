import '../map/transition_base_type.dart';
import '../resource/resource_type.dart';
import 'building_type.dart';

class UpgradeCheck {
  final bool canUpgrade;
  final bool isMaxLevel;
  final Map<ResourceType, int> missingResources;
  final Map<BuildingType, int> missingPrerequisites;
  final TransitionBaseType? missingCapturedBase;
  final bool missingCapturedKernel;

  const UpgradeCheck({
    required this.canUpgrade,
    this.isMaxLevel = false,
    this.missingResources = const {},
    this.missingPrerequisites = const {},
    this.missingCapturedBase,
    this.missingCapturedKernel = false,
  });
}
