import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';
import 'package:abyss/presentation/screens/game/game_screen_army_tab.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const scout = UnitType.scout, harpoonist = UnitType.harpoonist;

  /// A player with a barracks at [barracks] and [each] of every resource.
  Player rich({int barracks = 3, int each = 1000}) {
    final player =
        Player(name: 'Nemo')
          ..buildings[BuildingType.barracks]!.level = barracks
          ..buildings[BuildingType.headquarters]!.level = 10;
    for (final type in ResourceType.values) {
      player.resources[type]!.amount = each;
    }
    return player;
  }

  group('recruitableUnitsOf', () {
    test('the unlocked units one can pay at least one of', () {
      expect(recruitableUnitsOf(rich(barracks: 2)), {
        scout,
        harpoonist,
        UnitType.abyssAdmiral,
      });
    });

    test('none before the barracks is built', () {
      expect(recruitableUnitsOf(rich(barracks: 0)), isEmpty);
    });

    test('a type already recruited this turn is not recruitable again', () {
      final player = rich()..recruitedUnitTypes.add(scout);
      expect(recruitableUnitsOf(player), isNot(contains(scout)));
      expect(recruitableUnitsOf(player), contains(harpoonist));
    });

    test('a type one cannot pay is not recruitable', () {
      final player = rich(each: 0);
      player.resources[ResourceType.algae]!.amount = 10;
      player.resources[ResourceType.coral]!.amount = 5;
      expect(recruitableUnitsOf(player), {scout});
    });

    test('a degraded barracks costs twice as much', () {
      final player = rich(each: 0)
        ..buildings[BuildingType.headquarters]!.level = 1;
      player.resources[ResourceType.algae]!.amount = 10;
      player.resources[ResourceType.coral]!.amount = 5;
      expect(player.isDegraded(BuildingType.barracks), isTrue);
      expect(recruitableUnitsOf(player), isEmpty);
      player.resources[ResourceType.algae]!.amount = 20;
      player.resources[ResourceType.coral]!.amount = 10;
      expect(recruitableUnitsOf(player), {scout});
    });
  });

  test('armyCountsOf counts every place, the kernel garrison included', () {
    final player = Player(
      name: 'Nemo',
      unitsPerLevel: {
        1: {scout: Unit(type: scout, count: 10)},
        2: {
          scout: Unit(type: scout, count: 4),
          harpoonist: Unit(type: harpoonist, count: 2),
        },
        KernelGarrison.stockKey: {harpoonist: Unit(type: harpoonist, count: 5)},
      },
    );
    expect(armyCountsOf(player), {scout: 14, harpoonist: 7});
  });
}
