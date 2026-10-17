import 'package:abyss/domain/action/spy_base_action.dart';
import 'package:abyss/domain/faction/faction_war.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/base_attack_helper.dart';
import '../../helpers/faction_war_helper.dart';

void main() {
  test('it spies on a base before it attacks it', () {
    final war = warGame();
    war.see(war.human);

    war.play();

    expect(war.attacker.intel[war.human.id], isNotNull);
    expect(standing(war.attacker, UnitType.scout), 1);
    expect(war.human.raidState.attacks, hasLength(1));
  });

  test('without a scout it attacks nothing blind', () {
    final war = warGame();
    war.see(war.human);
    station(war.attacker, horde);

    war.play();

    expect(war.attacker.intel, isEmpty);
    expect(war.human.raidState.attacks, isEmpty);
  });

  test('it reads the report, not the base: an army that left can surprise', () {
    final war = warGame();
    war.see(war.human);
    SpyBaseAction(targetPlayerId: war.human.id)
        .execute(war.game, war.attacker);
    station(war.human, wall);

    war.play();

    expect(war.human.raidState.attacks, hasLength(1),
        reason: 'the fresh report said the base was empty');
    expect(standing(war.attacker, UnitType.scout), 1,
        reason: 'a fresh report is not paid for again');
  });

  test('a stale report is renewed before the attack', () {
    final war = warGame();
    war.see(war.human);
    SpyBaseAction(targetPlayerId: war.human.id)
        .execute(war.game, war.attacker);
    war.game.turn += 12;
    while (!isDue(war)) {
      war.game.turn++;
    }
    station(war.human, wall);

    war.play();

    expect(war.attacker.intel[war.human.id]!.turn, war.game.turn);
    expect(war.human.raidState.attacks, isEmpty,
        reason: 'the renewed report shows the wall');
  });

  test('it spies the base it knows before choosing the weakest', () {
    final war = warGame();
    war.see(war.human);
    war.see(war.rival);
    station(war.human, wall);

    war.play();

    expect(war.attacker.intel.keys,
        containsAll(<String>[war.human.id, war.rival.id]));
    expect(standing(war.attacker, UnitType.scout), 0);
  });
}

bool isDue(War war) =>
    war.game.factions.isNotEmpty &&
    FactionWar.isDue(war.game.turn, war.game.factions[0].personality);
