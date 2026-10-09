import 'dart:math';

import 'package:hive_ce/hive.dart';

import '../resource/resource_type.dart';

part 'difficulty.g.dart';

/// How hard the depths are, picked when a new game starts.
///
/// Two levers: the production of the buildings and the size of the
/// monster waves (raids on the base and krakens on the volcanic kernel).
/// Calibrated with the simulator on two reference players, the plan of a
/// human win played again with other dice and the careful script
/// (conquest): about 50 % of wins in easy, 15 % in normal, 5 % in hard.
@HiveType(typeId: 49)
enum Difficulty {
  @HiveField(0)
  easy(resourcePercent: 125, monsterPercent: 80),
  @HiveField(1)
  normal(resourcePercent: 100, monsterPercent: 100),
  @HiveField(2)
  hard(resourcePercent: 85, monsterPercent: 110);

  const Difficulty({
    required this.resourcePercent,
    required this.monsterPercent,
  });

  /// Production of algae, coral and ore, in percent of the normal one.
  final int resourcePercent;

  /// Monsters of a raid or a kraken wave, in percent of the normal one.
  final int monsterPercent;

  /// The resources scaled by the difficulty; energy and pearls are not.
  static const Set<ResourceType> scaledResources = <ResourceType>{
    ResourceType.algae,
    ResourceType.coral,
    ResourceType.ore,
  };

  /// [production] of the buildings, scaled in place.
  Map<ResourceType, int> scaleProduction(Map<ResourceType, int> production) {
    for (final ResourceType type in scaledResources) {
      final int? amount = production[type];
      if (amount != null && amount > 0) {
        production[type] = amount * resourcePercent ~/ 100;
      }
    }
    return production;
  }

  /// [count] monsters of the normal game, scaled; at least one.
  int monsters(int count) => max(1, count * monsterPercent ~/ 100);
}
