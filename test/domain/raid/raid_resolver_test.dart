import 'dart:math';

import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/raid/noise_rules.dart';
import 'package:abyss/domain/raid/raid_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

import 'raid_test_helper.dart';

void main() {
  test('every turn adds the base noise', () {
    final player = raidPlayer();
    final outcome = RaidResolver.resolve(player, 3);
    expect(player.raidState.noise, NoiseRules.perTurn);
    expect(outcome.report, isNull);
    expect(outcome.announced, isNull);
  });

  test('a full gauge announces a raid two turns ahead', () {
    final player = raidPlayer()..raidState.addNoise(NoiseRules.threshold);
    final outcome = RaidResolver.resolve(player, 12);
    expect(outcome.announced, isNotNull);
    expect(outcome.announcedTurn, 14);
    expect(player.raidState.arrivalTurn, 14);
    expect(player.raidState.noise, 0);
  });

  test('no raid hits before the first raid turn', () {
    final player = raidPlayer()..raidState.addNoise(NoiseRules.threshold);
    final outcome = RaidResolver.resolve(player, 4);
    expect(outcome.announcedTurn, NoiseRules.firstRaidTurn);
  });

  test('the gauge cannot announce a second raid during an alert', () {
    final player = raidPlayer()..raidState.addNoise(NoiseRules.threshold);
    RaidResolver.resolve(player, 12);
    player.raidState.addNoise(NoiseRules.threshold);
    final outcome = RaidResolver.resolve(player, 13);
    expect(outcome.announced, isNull);
    expect(player.raidState.arrivalTurn, 14);
  });

  test('the raid is fought at the end of its arrival turn', () {
    final player = raidPlayer();
    player.raidState.announce(
      const MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 5),
      14,
    );
    expect(RaidResolver.resolve(player, 13).report, isNull);
    final outcome = RaidResolver.resolve(player, 14, random: Random(2));
    expect(outcome.report!.victory, isFalse);
    expect(player.raidState.isIncoming, isFalse);
    expect(player.raidState.lostInARow, 1);
    expect(player.historyEntries.last, isA<RaidEntry>());
  });
}
