import '../map/transition_base_type.dart';
import '../resource/resource.dart';
import '../resource/resource_type.dart';
import '../worksite/worksite.dart';
import 'building.dart';
import 'building_cost_calculator.dart';
import 'building_type.dart';
import 'upgrade_check.dart';

/// Whether a building can go up a level right now, by the rules of the
/// upgrade action: what [check] says of its level, costs and
/// prerequisites, and whether a worksite is still [siteFree] this turn.
class UpgradeReadiness {
  final UpgradeCheck check;

  /// Whether a building site is still free this turn.
  final bool siteFree;

  const UpgradeReadiness({required this.check, required this.siteFree});

  /// The readiness of the building of [type] among [buildings], paid
  /// from [resources], the worksite of the turn being [worksite].
  factory UpgradeReadiness.of(
    BuildingType type, {
    required Map<BuildingType, Building> buildings,
    required Map<ResourceType, Resource> resources,
    required Worksite worksite,
    Set<TransitionBaseType> capturedBaseTypes = const {},
    bool isVolcanicKernelCaptured = false,
    int discountPercent = 0,
  }) {
    final calculator = BuildingCostCalculator(discountPercent: discountPercent);
    final hqLevel = buildings[BuildingType.headquarters]?.level ?? 0;
    return UpgradeReadiness(
      check: calculator.checkUpgrade(
        type: type,
        currentLevel: buildings[type]?.level ?? 0,
        resources: resources,
        allBuildings: buildings,
        capturedBaseTypes: capturedBaseTypes,
        isVolcanicKernelCaptured: isVolcanicKernelCaptured,
      ),
      siteFree: worksite.freeBuildSites(hqLevel) > 0,
    );
  }

  /// Whether the building can go up a level now: a free worksite, the
  /// costs paid, every requirement met and its maximum not reached.
  bool get isReady => siteFree && check.canUpgrade;

  /// Whether something else than resources or a worksite holds it back:
  /// a building to raise first, a base or the volcanic core to capture.
  bool get isLocked =>
      check.missingPrerequisites.isNotEmpty ||
      check.missingCapturedBase != null ||
      check.missingCapturedKernel;
}
