import 'dart:math';

import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/volcano/volcano_resolver.dart';
import 'package:abyss/domain/volcano/volcano_state.dart';
import 'package:abyss/domain/volcano/volcano_wave_factory.dart';
import 'package:flutter_test/flutter_test.dart';

import 'volcano_test_helper.dart';

void main() {
  int full(int level, Difficulty difficulty) => VolcanoWaveFactory.krakensFor(
    level,
    monsterPercent: difficulty.monsterPercent,
  );

  int announced(Player player, {Difficulty d = Difficulty.normal}) =>
      VolcanoResolver.resolve(player, 40, difficulty: d).announced!.unitCount;

  test('a gentle wave holds half the krakens, rounded up, at least one', () {
    expect(VolcanoWaveFactory.krakensFor(9, firstWave: true), 7);
    expect(VolcanoWaveFactory.krakensFor(1, firstWave: true), 2);
    expect(VolcanoWaveFactory.krakensFor(3, firstWave: true), 3);
    expect(
      VolcanoWaveFactory.krakensFor(0, monsterPercent: 1, firstWave: true),
      1,
    );
  });

  test('a player who never fought a wave draws a half-strength one', () {
    final player = volcanoPlayer(kernelLevel: 9);
    expect(player.volcanoState.wavesFought, 0);
    final int size = announced(player);
    expect(size, (full(9, Difficulty.normal) + 1) ~/ 2);
    expect(player.volcanoState.incoming!.unitCount, size);
    expect(player.volcanoState.arrivalTurn, 41);
  });

  test('the wave after the first one is full strength again', () {
    final player = volcanoPlayer(kernelLevel: 6);
    VolcanoResolver.resolve(player, 40);
    final outcome = VolcanoResolver.resolve(player, 41, random: Random(1));
    expect(
      outcome.report!.wave.unitCount,
      (full(6, Difficulty.normal) + 1) ~/ 2,
    );
    expect(player.volcanoState.wavesFought, 1);
    expect(outcome.announced!.unitCount, full(5, Difficulty.normal));
  });

  test('a save with waves already fought draws a normal wave', () {
    for (final VolcanoState state in [
      VolcanoState(wavesRepelled: 2),
      VolcanoState(levelsLost: 1),
    ]) {
      final player = volcanoPlayer(kernelLevel: 9);
      player.volcanoState
        ..wavesRepelled = state.wavesRepelled
        ..levelsLost = state.levelsLost;
      expect(announced(player), full(9, Difficulty.normal));
    }
  });

  test('the difficulty still scales the gentle wave', () {
    for (final Difficulty d in Difficulty.values) {
      final player = volcanoPlayer(kernelLevel: 9);
      expect(announced(player, d: d), (full(9, d) + 1) ~/ 2);
    }
    expect(
      announced(volcanoPlayer(kernelLevel: 9), d: Difficulty.easy),
      lessThan(announced(volcanoPlayer(kernelLevel: 9), d: Difficulty.hard)),
    );
  });

  test('a faction holding the kernel gets the same gentle first wave', () {
    final player = volcanoPlayer(kernelLevel: 9);
    final int size =
        VolcanoResolver.resolve(
          player,
          40,
          isFaction: true,
        ).announced!.unitCount;
    final int percent = Difficulty.normal.monsterPercentFor(faction: true);
    expect(
      size,
      VolcanoWaveFactory.krakensFor(
        9,
        monsterPercent: percent,
        firstWave: true,
      ),
    );
  });
}
