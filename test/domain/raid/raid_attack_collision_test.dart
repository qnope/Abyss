import 'package:abyss/domain/raid/announced_attack.dart';
import 'package:abyss/domain/raid/noise_rules.dart';
import 'package:abyss/domain/raid/raid_resolver.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'raid_test_helper.dart';

AnnouncedAttack _attackFor(int turn) => AnnouncedAttack(
  attackerId: 'faction-x',
  units: const {UnitType.harpoonist: 5},
  arrivalTurn: turn,
  seed: 1,
);

void main() {
  test('a raid announced for the turn of an attack comes a turn later', () {
    final player = raidPlayer();
    player.raidState.attacks.add(_attackFor(14));
    player.raidState.noise = NoiseRules.threshold;

    final outcome = RaidResolver.resolve(player, 12);

    expect(outcome.announced, isNotNull);
    expect(outcome.announcedTurn, 15);
    expect(player.raidState.arrivalTurn, 15);
  });

  test('a raid announced for any other turn keeps its date', () {
    final player = raidPlayer();
    player.raidState.attacks.add(_attackFor(13));
    player.raidState.noise = NoiseRules.threshold;

    expect(RaidResolver.resolve(player, 12).announcedTurn, 14);
  });
}
