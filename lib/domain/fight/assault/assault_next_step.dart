import '../../building/building_type.dart';

/// The passage building to raise once a post is captured, and whether the
/// headquarters already allow it.
class AssaultNextStep {
  final BuildingType building;
  final int requiredHq;
  final int currentHq;

  const AssaultNextStep({
    required this.building,
    required this.requiredHq,
    required this.currentHq,
  });

  /// Whether the headquarters are high enough to build it now.
  bool get isReady => currentHq >= requiredHq;
}
