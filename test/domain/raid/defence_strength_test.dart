import 'package:abyss/domain/raid/defence_strength.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'raid_test_helper.dart';

void main() {
  test('an empty base has no strength', () {
    expect(DefenceStrength.of(raidPlayer()), 0);
  });

  test('a unit weighs its HP times its ATK against a level 1 monster', () {
    // Harpoonist 15 × 5 = 75, a generic monster 10 × 3 = 30.
    final player = raidPlayer(units: {UnitType.harpoonist: 4});
    expect(DefenceStrength.of(player), 10);
  });

  test('every type on the base adds up, the admiral weighs nothing', () {
    final player = raidPlayer(
      units: {
        UnitType.harpoonist: 4, // 300
        UnitType.guardian: 3, // 25 × 2 × 3 = 150
        UnitType.abyssAdmiral: 1, // 0
      },
    );
    expect(DefenceStrength.of(player), 15);
  });

  test('units on deeper levels do not count', () {
    final player = raidPlayer();
    player.unitsPerLevel[2] = {
      UnitType.harpoonist: Unit(type: UnitType.harpoonist, count: 4),
    };
    expect(DefenceStrength.of(player), 0);
  });
}
