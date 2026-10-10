import 'dart:math';

import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/raid/noise_rules.dart';
import 'package:abyss/domain/raid/raid_resolver.dart';
import 'package:abyss/domain/volcano/volcano_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

import '../raid/raid_test_helper.dart';

void main() {
  test('monsters spend three quarters of their strength on a faction', () {
    expect(Difficulty.normal.monsterPercentFor(faction: false), 94);
    expect(Difficulty.normal.monsterPercentFor(faction: true), 70);
    expect(Difficulty.easy.monsterPercentFor(faction: true), 64);
    expect(Difficulty.hard.monsterPercentFor(faction: true), 76);
  });

  test('a raid on a faction is weaker than the same raid on the human', () {
    int raidSize({required bool faction}) {
      final player = raidPlayer()
        ..raidState.addNoise(NoiseRules.threshold)
        ..raidState.totalNoise = 4000;
      return RaidResolver.resolve(
        player,
        12,
        random: Random(1),
        difficulty: Difficulty.normal,
        isFaction: faction,
      ).announced!.unitCount;
    }

    expect(raidSize(faction: true), lessThan(raidSize(faction: false)));
  });

  test('a kraken wave on a faction kernel is weaker too', () {
    int krakens({required bool faction}) {
      final player = raidPlayer();
      player.buildings.values
          .firstWhere((b) => b.type.name == 'volcanicKernel')
          .level = 9;
      return VolcanoResolver.resolve(
        player,
        12,
        difficulty: Difficulty.normal,
        isFaction: faction,
      ).announced!.unitCount;
    }

    expect(krakens(faction: true), lessThan(krakens(faction: false)));
  });
}
