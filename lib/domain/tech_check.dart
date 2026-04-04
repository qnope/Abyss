import 'resource_type.dart';

class TechCheck {
  final bool canAct;
  final bool isMaxLevel;
  final Map<ResourceType, int> missingResources;
  final int requiredLabLevel;
  final int currentLabLevel;
  final bool branchLocked;
  final bool previousNodeMissing;

  const TechCheck({
    required this.canAct,
    this.isMaxLevel = false,
    this.missingResources = const {},
    this.requiredLabLevel = 0,
    this.currentLabLevel = 0,
    this.branchLocked = false,
    this.previousNodeMissing = false,
  });
}
