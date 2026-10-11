import 'dart:math';

import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/raid/noise_rules.dart';
import 'package:abyss/domain/raid/raid_resolver.dart';
import 'package:abyss/domain/volcano/volcano_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

import '../raid/raid_test_helper.dart';

void main() {
  test('a game without faction keeps the monsters it always had', () {
    expect(Difficulty.worldReliefPercent(0), 100);
    expect(Difficulty.normal.monsterPercentFor(faction: false), 94);
  });

  test('the more factions, the bigger the world and the lighter the raids', () {
    final reliefs = [
      for (final n in [0, 1, 3, 5, 10]) Difficulty.worldReliefPercent(n),
    ];
    expect(reliefs, [100, 97, 92, 87, 75]);
  });

  test('the relief eases the human only, never a faction', () {
    expect(
      Difficulty.normal.monsterPercentFor(faction: false, factions: 3),
      94 * 92 ~/ 100,
    );
    expect(
      Difficulty.normal.monsterPercentFor(faction: true, factions: 3),
      Difficulty.normal.monsterPercentFor(faction: true),
    );
  });

  test('a raid on the human is smaller in a world of ten factions', () {
    int raidSize(int factions) {
      final player =
          raidPlayer()
            ..raidState.addNoise(NoiseRules.threshold)
            ..raidState.totalNoise = 4000;
      return RaidResolver.resolve(
        player,
        12,
        random: Random(1),
        factions: factions,
      ).announced!.unitCount;
    }

    expect(raidSize(10), lessThan(raidSize(0)));
  });

  test('a kraken wave on the human kernel is lighter too', () {
    int krakens(int factions) {
      final player = raidPlayer();
      player
          .buildings
          .values
          .firstWhere((b) => b.type.name == 'volcanicKernel')
          .level = 9;
      return VolcanoResolver.resolve(
        player,
        12,
        factions: factions,
      ).announced!.unitCount;
    }

    expect(krakens(10), lessThan(krakens(0)));
  });
}
