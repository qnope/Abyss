import 'package:abyss/domain/action/attack_base_result.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/base_attack_helper.dart';
import '../../../helpers/two_player_game.dart';

AttackBaseResult _fight(TwoPlayerGame two, {Map<UnitType, int>? army}) {
  station(two.human, army ?? horde);
  return strike(two, army ?? horde).execute(two.game, two.human)
      as AttackBaseResult;
}

void main() {
  test('the defenders are the units standing on the base level', () {
    final two = assaultGame();
    station(two.rival, {UnitType.guardian: 4, UnitType.harpoonist: 6});
    two.rival.unitsPerLevel[2] = {
      UnitType.harpoonist: Unit(type: UnitType.harpoonist, count: 50),
    };

    final result = _fight(two);

    expect(result.defence.engaged, {
      UnitType.guardian: 4,
      UnitType.harpoonist: 6,
    });
    expect(result.defence.initial, hasLength(10));
    expect(
      result.defence.initial.every((c) => c.side == CombatSide.monster),
      isTrue,
    );
  });

  test('the Citadel rampart defends beside the units', () {
    final two = assaultGame();
    setLevel(two.rival, BuildingType.headquarters, 10);
    setLevel(two.rival, BuildingType.coralCitadel, 3);

    final result = _fight(two);

    final Combatant rampart = result.defence.initial.single;
    expect(rampart.typeKey, 'rampart');
    expect(rampart.maxHp, 120);
    expect(rampart.def, 7);
    expect(result.fight!.finalMonsterCount, 0);
  });

  test('a degraded Citadel defends with half of its force', () {
    final two = assaultGame();
    setLevel(two.rival, BuildingType.headquarters, 10);
    setLevel(two.rival, BuildingType.coralCitadel, 3);
    final strong = _fight(two).defence.initial.single;
    final fresh = assaultGame();
    setLevel(fresh.rival, BuildingType.coralCitadel, 3);
    setLevel(fresh.rival, BuildingType.headquarters, 1);

    final weak = _fight(fresh).defence.initial.single;

    expect(weak.maxHp, strong.maxHp ~/ 2);
    expect(weak.def, strong.def ~/ 2);
  });

  test('the attackers leave the base and the survivors come home', () {
    final two = assaultGame();

    final result = _fight(two);

    final home = standing(two.human, UnitType.harpoonist);
    expect(result.sent, {UnitType.harpoonist: 40});
    expect(home, 40 - (result.dead[UnitType.harpoonist] ?? 0));
    expect(result.victory, isTrue);
  });

  test('defenders that fall are wounded or dead, the rest stay home', () {
    final two = assaultGame();
    station(two.rival, {UnitType.harpoonist: 10});

    final result = _fight(two, army: {UnitType.harpoonist: 60});

    final lost = (result.defence.dead[UnitType.harpoonist] ?? 0);
    final wounded = (result.defence.wounded[UnitType.harpoonist] ?? 0);
    expect(lost + wounded, 10);
    expect(standing(two.rival, UnitType.harpoonist), 10 - lost);
  });

  test('an empty base falls without a fight', () {
    final two = assaultGame();

    final result = _fight(two);

    expect(result.victory, isTrue);
    expect(result.fight!.turnCount, 0);
  });
}
