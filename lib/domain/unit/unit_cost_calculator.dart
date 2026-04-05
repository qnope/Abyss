import 'dart:math';

import '../resource/resource.dart';
import '../resource/resource_type.dart';
import 'unit_type.dart';

class UnitCostCalculator {
  Map<ResourceType, int> recruitmentCost(UnitType type) => switch (type) {
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
    UnitType.siphoner => {
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

  Map<ResourceType, int> maintenanceCost(UnitType type) => switch (type) {
    UnitType.scout => {ResourceType.algae: 1},
    UnitType.harpoonist => {ResourceType.algae: 2},
    UnitType.guardian => {ResourceType.algae: 3},
    UnitType.domeBreaker => {ResourceType.algae: 2},
    UnitType.siphoner => {ResourceType.algae: 3},
    UnitType.saboteur => {ResourceType.algae: 2},
  };

  int unlockLevel(UnitType type) => switch (type) {
    UnitType.scout || UnitType.harpoonist => 1,
    UnitType.guardian || UnitType.domeBreaker => 3,
    UnitType.siphoner || UnitType.saboteur => 5,
  };

  bool isUnlocked(UnitType type, int barracksLevel) =>
      barracksLevel >= unlockLevel(type);

  int maxRecruitableCount(
    UnitType type,
    int barracksLevel,
    Map<ResourceType, Resource> resources,
  ) {
    final costs = recruitmentCost(type);
    var minAffordable = barracksLevel * 100;

    for (final entry in costs.entries) {
      final available = resources[entry.key]?.amount ?? 0;
      final affordable = available ~/ entry.value;
      minAffordable = min(minAffordable, affordable);
    }

    return max(0, minAffordable);
  }
}
