import 'package:abyss/domain/building/coral_citadel_rampart.dart';
import 'package:abyss/domain/fight/combat_role.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no rampart without a Citadel', () {
    expect(CoralCitadelRampart.combatantFor(0), isNull);
  });

  test('40 PV and one DEF point per level', () {
    final rampart = CoralCitadelRampart.combatantFor(3)!;
    expect(rampart.maxHp, 120);
    expect(rampart.def, 7);
    expect(rampart.atk, 0);
    expect(rampart.side, CombatSide.player);
  });

  test('the rampart taunts', () {
    final rampart = CoralCitadelRampart.combatantFor(1)!;
    expect(CombatRole.of(rampart), CombatRole.taunt);
  });
}
