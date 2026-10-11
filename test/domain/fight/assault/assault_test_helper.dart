import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';

/// Player with [stock] on [level] and its headquarters at [hq].
Player assaultPlayer({
  Map<UnitType, int> stock = const {},
  int level = 1,
  int hq = 1,
}) =>
    Player(
      id: 'p1',
      name: 'Test',
      buildings: {
        for (final t in BuildingType.values)
          t: Building(
            type: t,
            level: t == BuildingType.headquarters ? hq : 0,
          ),
      },
      unitsPerLevel: {
        level: {
          for (final t in UnitType.values)
            t: Unit(type: t, count: stock[t] ?? 0),
        },
      },
    );
