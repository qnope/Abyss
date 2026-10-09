import 'dart:math';

import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/volcano_resolver.dart';
import 'package:abyss/domain/volcano/volcano_wave_factory.dart';
import 'package:flutter_test/flutter_test.dart';

import 'volcano_test_helper.dart';

void main() {
  int kernelLevel(p) => p.buildings[BuildingType.volcanicKernel]!.level;

  test('no wave while the kernel is at level 0', () {
    final player = volcanoPlayer(kernelLevel: 0);
    final outcome = VolcanoResolver.resolve(player, 40);
    expect(outcome.announced, isNull);
    expect(player.volcanoState.isIncoming, isFalse);
  });

  test('a kernel at level 1 or more draws a kraken wave for next turn', () {
    final player = volcanoPlayer(kernelLevel: 3);
    final outcome = VolcanoResolver.resolve(player, 40);
    expect(outcome.announced!.family, MonsterFamily.kraken);
    expect(outcome.announced!.unitCount, VolcanoWaveFactory.krakensFor(3));
    expect(player.volcanoState.arrivalTurn, 41);
  });

  test('the waves stop once the kernel reaches level 10', () {
    final player = volcanoPlayer(kernelLevel: 10);
    expect(VolcanoResolver.resolve(player, 40).announced, isNull);
  });

  test('a wave beating an empty garrison takes a level off', () {
    final player = volcanoPlayer(kernelLevel: 4);
    VolcanoResolver.resolve(player, 40);
    final outcome = VolcanoResolver.resolve(player, 41, random: Random(1));
    expect(outcome.report!.victory, isFalse);
    expect(kernelLevel(player), 3);
    expect(player.volcanoState.levelsLost, 1);
    expect(player.historyEntries.last, isA<VolcanoEntry>());
    expect(outcome.announced!.unitCount, VolcanoWaveFactory.krakensFor(3));
  });

  test('a strong garrison holds the kernel', () {
    final player = volcanoPlayer(
      kernelLevel: 2,
      garrison: {UnitType.domeBreaker: 60, UnitType.guardian: 30},
    );
    VolcanoResolver.resolve(player, 40);
    final outcome = VolcanoResolver.resolve(player, 41, random: Random(2));
    expect(outcome.report!.victory, isTrue);
    expect(kernelLevel(player), 2);
    expect(player.volcanoState.wavesRepelled, 1);
  });
}
