import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';

/// Player with 1000 of every resource, the given units on the base level
/// and a Coral Citadel at [citadelLevel].
Player raidPlayer({
  Map<UnitType, int> units = const {},
  int citadelLevel = 0,
}) {
  final player = Player(
    id: 'p1',
    name: 'Test',
    resources: {
      for (final type in ResourceType.values)
        type: Resource(type: type, amount: 1000, maxStorage: 100000),
    },
  );
  player.buildings[BuildingType.coralCitadel] =
      Building(type: BuildingType.coralCitadel, level: citadelLevel);
  units.forEach((type, count) => player.unitsOnLevel(1)[type]!.count = count);
  return player;
}

int unitsOnBase(Player player) => player
    .unitsOnLevel(1)
    .values
    .fold<int>(0, (sum, unit) => sum + unit.count);
