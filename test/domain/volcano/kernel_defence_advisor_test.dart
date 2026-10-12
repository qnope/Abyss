import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/kernel_defence_advisor.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';
import 'package:abyss/domain/volcano/volcano_wave_factory.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/kernel_garrison_helpers.dart';
import '../../helpers/objective_helpers.dart';

void main() {
  final wave = VolcanoWaveFactory.fromKernelLevel(1);

  test('an empty garrison needs units against a wave', () {
    final player = kernelGarrisonGame(onVolcano: 0).humanPlayer;
    final int? needed = KernelDefenceAdvisor.unitsFor(player, wave);
    expect(needed, greaterThan(0));
    expect(KernelDefenceAdvisor.unitsFor(player, wave), needed);
  });

  test('counts the garrison already inside', () {
    final player = kernelGarrisonGame(onVolcano: 0, garrisoned: 2).humanPlayer;
    expect(
      KernelDefenceAdvisor.unitsFor(player, wave),
      greaterThanOrEqualTo(2),
    );
  });

  test('a garrison that holds needs no more', () {
    final player = kernelGarrisonGame(onVolcano: 0).humanPlayer;
    setUnits(player, UnitType.domeBreaker, 40, level: KernelGarrison.stockKey);
    expect(KernelDefenceAdvisor.unitsFor(player, wave), 40);
  });

  test('the magma rampart of a higher kernel helps', () {
    final player = kernelGarrisonGame(onVolcano: 0).humanPlayer;
    final int low = KernelDefenceAdvisor.unitsFor(player, wave)!;
    player.buildings[BuildingType.volcanicKernel]!.level = 9;
    expect(
      KernelDefenceAdvisor.unitsFor(player, wave)!,
      lessThanOrEqualTo(low),
    );
  });

  test('no number of units holds a flood', () {
    const flood = MonsterLair(
      difficulty: MonsterDifficulty.hard,
      family: MonsterFamily.kraken,
      unitCount: 2000,
    );
    final player = kernelGarrisonGame(onVolcano: 0).humanPlayer;
    expect(KernelDefenceAdvisor.unitsFor(player, flood), isNull);
  });
}
