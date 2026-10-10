import 'package:abyss/domain/action/attack_base_result.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/base_attack_helper.dart';
import '../../../helpers/two_player_game.dart';

AttackBaseResult _win(TwoPlayerGame two, {Map<UnitType, int>? army}) {
  station(two.human, army ?? horde);
  return strike(two, army ?? horde).execute(two.game, two.human)
      as AttackBaseResult;
}

int _hq(TwoPlayerGame two) =>
    two.rival.buildings[BuildingType.headquarters]!.level;
int _citadel(TwoPlayerGame two) =>
    two.rival.buildings[BuildingType.coralCitadel]!.level;

void main() {
  test('a won attack lowers the rampart by two levels', () {
    final two = assaultGame();
    setLevel(two.rival, BuildingType.coralCitadel, 4);

    final result = _win(two);

    expect(result.victory, isTrue);
    expect(_citadel(two), 2);
    expect(_hq(two), 5);
    expect(result.damage.rampartBefore, 4);
    expect(result.damage.rampartAfter, 2);
  });

  test('the rampart stops at level 0 and spares the headquarters', () {
    final two = assaultGame();
    setLevel(two.rival, BuildingType.coralCitadel, 1);

    _win(two);

    expect(_citadel(two), 0);
    expect(_hq(two), 5);
  });

  test('without a rampart the headquarters falls by one level', () {
    final two = assaultGame();

    final result = _win(two);

    expect(_hq(two), 4);
    expect(result.damage.headquartersBefore, 5);
    expect(result.damage.headquartersAfter, 4);
  });

  test('the headquarters never falls under level 1', () {
    final two = assaultGame();
    setLevel(two.rival, BuildingType.headquarters, 1);

    _win(two);

    expect(_hq(two), 1);
  });

  test('a won attack pillages 30% of the stocks, pearls aside', () {
    final two = assaultGame();
    two.rival.resources[ResourceType.coral]!.amount = 1000;
    two.rival.resources[ResourceType.pearl]!.amount = 50;
    two.human.resources[ResourceType.coral]!.amount = 0;

    final result = _win(two);

    expect(result.damage.pillaged[ResourceType.coral], 300);
    expect(two.rival.resources[ResourceType.coral]!.amount, 700);
    expect(two.human.resources[ResourceType.coral]!.amount, 300);
    expect(result.damage.pillaged.containsKey(ResourceType.pearl), isFalse);
    expect(two.rival.resources[ResourceType.pearl]!.amount, 50);
    expect(two.human.resources[ResourceType.pearl]!.amount, 5);
  });

  test('the loot stops at the storage of the attacker', () {
    final two = assaultGame();
    two.rival.resources[ResourceType.coral]!.amount = 1000;
    two.human.resources[ResourceType.coral] = Resource(
      type: ResourceType.coral,
      amount: 4900,
      maxStorage: 5000,
    );

    final result = _win(two);

    expect(two.human.resources[ResourceType.coral]!.amount, 5000);
    expect(result.damage.loot[ResourceType.coral], 100);
    expect(two.rival.resources[ResourceType.coral]!.amount, 700);
  });

  test('a lost attack takes and breaks nothing and costs units', () {
    final two = assaultGame();
    station(two.rival, wall);
    setLevel(two.rival, BuildingType.coralCitadel, 4);
    final coral = two.rival.resources[ResourceType.coral]!.amount;
    final mine = two.human.resources[ResourceType.coral]!.amount;

    final result = _win(two, army: {UnitType.scout: 3});

    expect(result.victory, isFalse);
    expect(_citadel(two), 4);
    expect(_hq(two), 5);
    expect(result.damage.pillaged, isEmpty);
    expect(two.rival.resources[ResourceType.coral]!.amount, coral);
    expect(two.human.resources[ResourceType.coral]!.amount, mine);
    final survivors = standing(two.human, UnitType.scout);
    expect(survivors, lessThanOrEqualTo(3));
    expect(
      survivors + (result.dead[UnitType.scout] ?? 0) - 3,
      lessThanOrEqualTo(0),
    );
  });
}
