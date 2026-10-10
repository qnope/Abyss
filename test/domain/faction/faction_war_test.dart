import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/faction/faction_war.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/objective/objective_migration.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/base_attack_helper.dart';
import '../../helpers/faction_war_helper.dart';

void main() {
  test('it announces an attack on the human it has seen and can beat', () {
    final war = warGame();
    war.see(war.human);

    war.play();

    final attack = war.human.raidState.attacks.single;
    expect(attack.attackerId, war.attacker.id);
    expect(attack.units, horde);
    expect(attack.arrivalTurn, war.game.turn + 2);
  });

  test('it only strikes on its slot, every few turns', () {
    final war = warGame();
    war.see(war.human);
    war.game.turn++;

    war.play();

    expect(war.human.raidState.attacks, isEmpty);
  });

  test('every personality has a slot every cadence turns, no more', () {
    for (final p in FactionPersonality.values) {
      final slots = [
        for (var t = 1; t <= 60; t++)
          if (FactionWar.isDue(t, p)) t,
      ];
      expect(slots, hasLength(10));
      for (var i = 1; i < slots.length; i++) {
        expect(slots[i] - slots[i - 1], FactionWar.cadence);
      }
    }
  });

  test('it leaves alone a base its fog never showed', () {
    final war = warGame();

    war.play();

    expect(war.human.raidState.attacks, isEmpty);
  });

  test('it does not attack a defence stronger than its army', () {
    final war = warGame();
    war.see(war.human);
    station(war.human, wall);

    war.play();

    expect(war.human.raidState.attacks, isEmpty);
    expect(standing(war.attacker, UnitType.harpoonist), 40);
  });

  test('it picks the weakest base it knows: a faction is hit at once', () {
    final war = warGame();
    war.see(war.human);
    war.see(war.rival);
    station(war.human, wall);

    war.play();

    expect(war.human.raidState.attacks, isEmpty);
    expect(
      war.rival.historyEntries.whereType<BaseAssaultEntry>(),
      hasLength(1),
    );
    expect(
      war.attacker.historyEntries.whereType<BaseAssaultEntry>(),
      hasLength(1),
    );
  });

  test('it announces nothing while the tutorial of the human runs', () {
    final war = warGame();
    war.see(war.human);
    ObjectiveMigration.stateOf(war.game, war.human).tutorialEnabled = true;

    war.play();

    expect(war.human.raidState.attacks, isEmpty);
  });

  test('it has one attack pending at a time', () {
    final war = warGame();
    war.see(war.human);

    war.play();
    war.play();

    expect(war.human.raidState.attacks, hasLength(1));
  });

  test('scouts and admirals stay home', () {
    final war = warGame();
    war.see(war.human);
    station(war.attacker, {...horde, UnitType.scout: 3});

    war.play();

    expect(war.human.raidState.attacks.single.units, horde);
  });
}
