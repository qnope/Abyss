import 'package:abyss/domain/building/coral_citadel_rampart.dart';
import 'package:abyss/domain/fight/combat_role.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no rampart without a Citadel', () {
    expect(CoralCitadelRampart.combatantFor(0), isNull);
    expect(CoralCitadelRampart.label(0), 'aucun');
  });

  test('40 PV and one DEF point per level', () {
    final rampart = CoralCitadelRampart.combatantFor(3)!;
    expect(rampart.maxHp, 120);
    expect(rampart.def, 7);
    expect(rampart.atk, 0);
    expect(rampart.side, CombatSide.player);
    expect(CoralCitadelRampart.label(3), '120 PV, DEF 7');
  });

  test('the rampart taunts', () {
    final rampart = CoralCitadelRampart.combatantFor(1)!;
    expect(CombatRole.of(rampart), CombatRole.taunt);
  });
}
