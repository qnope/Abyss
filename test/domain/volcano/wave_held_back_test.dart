import 'dart:math';

import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/volcano/volcano_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

import 'volcano_test_helper.dart';

void main() {
  int kernelLevel(p) => p.buildings[BuildingType.volcanicKernel]!.level;

  test('a wave due the turn the kernel lost a siege comes a turn later', () {
    final player = volcanoPlayer(kernelLevel: 4);
    VolcanoResolver.resolve(player, 40);
    final wave = player.volcanoState.incoming;
    player.raidState.kernelSiegeLostTurn = 41;

    final outcome = VolcanoResolver.resolve(player, 41, random: Random(1));

    expect(outcome.report, isNull);
    expect(kernelLevel(player), 4);
    expect(player.volcanoState.wavesFought, 0);
    expect(player.volcanoState.incoming, same(wave));
    expect(player.volcanoState.arrivalTurn, 42);
    expect(outcome.announced, same(wave));
  });

  test('the held-back wave hits at the end of the next turn', () {
    final player = volcanoPlayer(kernelLevel: 4);
    VolcanoResolver.resolve(player, 40);
    player.raidState.kernelSiegeLostTurn = 41;
    VolcanoResolver.resolve(player, 41, random: Random(1));

    final outcome = VolcanoResolver.resolve(player, 42, random: Random(1));

    expect(outcome.report!.victory, isFalse);
    expect(kernelLevel(player), 3);
    expect(player.volcanoState.arrivalTurn, 43);
  });

  test('a siege lost an earlier turn does not hold the wave back', () {
    final player = volcanoPlayer(kernelLevel: 4);
    VolcanoResolver.resolve(player, 40);
    player.raidState.kernelSiegeLostTurn = 40;

    final outcome = VolcanoResolver.resolve(player, 41, random: Random(1));

    expect(outcome.report, isNotNull);
    expect(kernelLevel(player), 3);
  });

  test('a faction kernel is held back the same way', () {
    final player = volcanoPlayer(kernelLevel: 4);
    VolcanoResolver.resolve(player, 40, isFaction: true);
    player.raidState.kernelSiegeLostTurn = 41;

    final outcome = VolcanoResolver.resolve(
      player,
      41,
      random: Random(1),
      isFaction: true,
    );

    expect(outcome.report, isNull);
    expect(player.volcanoState.arrivalTurn, 42);
  });

  test('a siege that takes the kernel calls the wave off', () {
    final player = volcanoPlayer(kernelLevel: 4);
    VolcanoResolver.resolve(player, 40);
    player.buildings[BuildingType.volcanicKernel]!.level = 0;
    player.raidState.kernelSiegeLostTurn = 41;

    final outcome = VolcanoResolver.resolve(player, 41, random: Random(1));

    expect(outcome.report, isNull);
    expect(outcome.announced, isNull);
    expect(player.volcanoState.isIncoming, isFalse);
    expect(player.volcanoState.wavesFought, 0);
  });
}
