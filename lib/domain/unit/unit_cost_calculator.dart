import 'dart:math';

import '../resource/resource.dart';
import '../resource/resource_type.dart';
import 'unit_type.dart';

class UnitCostCalculator {
  /// Cost of one [type], twice as much when the barracks are [degraded].
  Map<ResourceType, int> recruitmentCost(
    UnitType type, {
    bool degraded = false,
  }) {
    final Map<ResourceType, int> base = _baseCost(type);
    return degraded ? base.map((r, v) => MapEntry(r, v * 2)) : base;
  }

  Map<ResourceType, int> _baseCost(UnitType type) => switch (type) {
    UnitType.scout => {
      ResourceType.algae: 10,
      ResourceType.coral: 5,
    },
    UnitType.harpoonist => {
      ResourceType.algae: 15,
      ResourceType.coral: 10,
      ResourceType.ore: 5,
    },
    UnitType.guardian => {
      ResourceType.coral: 20,
      ResourceType.ore: 15,
    },
    UnitType.domeBreaker => {
      ResourceType.ore: 25,
      ResourceType.energy: 15,
    },
    UnitType.abyssAdmiral => {
      ResourceType.algae: 20,
      ResourceType.energy: 10,
      ResourceType.pearl: 2,
    },
    UnitType.saboteur => {
      ResourceType.coral: 15,
      ResourceType.energy: 20,
      ResourceType.pearl: 3,
    },
  };

  int unlockLevel(UnitType type) => switch (type) {
    UnitType.scout || UnitType.harpoonist => 1,
    UnitType.guardian || UnitType.domeBreaker => 3,
    UnitType.abyssAdmiral => 2,
    UnitType.saboteur => 5,
  };

  bool isUnlocked(UnitType type, int barracksLevel) =>
      barracksLevel >= unlockLevel(type);

  int maxRecruitableCount(
    UnitType type,
    int barracksLevel,
    Map<ResourceType, Resource> resources, {
    bool degraded = false,
  }) {
    final costs = recruitmentCost(type, degraded: degraded);
    var minAffordable = barracksLevel * 100;

    for (final entry in costs.entries) {
      final available = resources[entry.key]?.amount ?? 0;
      final affordable = available ~/ entry.value;
      minAffordable = min(minAffordable, affordable);
    }

    return max(0, minAffordable);
  }
}
