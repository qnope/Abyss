import 'dart:math';

import 'package:abyss/domain/action/attack_volcanic_kernel_action.dart';
import 'package:abyss/domain/action/attack_volcanic_kernel_result.dart';
import 'package:abyss/domain/action/upgrade_building_action.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game_statistics_calculator.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/game/victory_checker.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_generator.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'end_game_integration_helper.dart';

void main() {
  test('Level 3 map contains volcanic kernel at center', () {
    final result = MapGenerator.generate(seed: 42, level: 3);
    final map = result.map;
    final cell = map.cellAt(kKernelX, kKernelY);
    expect(cell.content, CellContentType.volcanicKernel);

    var kernelCount = 0;
    for (final c in map.cells) {
      if (c.content == CellContentType.volcanicKernel) kernelCount++;
    }
    expect(kernelCount, 1);
  });

  test('capture volcanic kernel with overwhelming force', () {
    final s = buildEndGameScenario();
    final action = AttackVolcanicKernelAction(
      targetX: kKernelX,
      targetY: kKernelY,
      level: 3,
      selectedUnits: {
        UnitType.abyssAdmiral: 50,
        UnitType.domeBreaker: 200,
      },
      random: Random(0),
    );

    final result = action.execute(s.game, s.player);
    final r = result as AttackVolcanicKernelResult;
    expect(r.isSuccess, isTrue);
    expect(r.victory, isTrue);
    expect(r.captured, isTrue);
    expect(s.game.isVolcanicKernelCapturedBy(s.player.id), isTrue);
  });

  test('build volcanic kernel to level 10', () {
    final s = buildEndGameScenario();
    // Capture kernel first.
    final map = s.game.levels[3]!;
    final cell = map.cellAt(kKernelX, kKernelY);
    map.setCell(
      kKernelX, kKernelY,
      cell.copyWith(collectedBy: s.player.id),
    );

    final action = UpgradeBuildingAction(
      buildingType: BuildingType.volcanicKernel,
    );

    for (var i = 0; i < 10; i++) {
      final result = action.execute(s.game, s.player);
      expect(result.isSuccess, isTrue, reason: 'upgrade $i failed');
    }
    expect(
      s.player.buildings[BuildingType.volcanicKernel]!.level,
      10,
    );
  });

  test('victory triggered at volcanic kernel level 10', () {
    final s = buildEndGameScenario();
    s.player.buildings[BuildingType.volcanicKernel]!.level = 10;
    expect(VictoryChecker.check(s.game), GameStatus.victory);
  });

  test('free play after victory returns null', () {
    final s = buildEndGameScenario();
    s.player.buildings[BuildingType.volcanicKernel]!.level = 10;
    s.game.status = GameStatus.freePlay;
    expect(VictoryChecker.check(s.game), isNull);
  });

  test('statistics accuracy after capture', () {
    final s = buildEndGameScenario();
    s.game.turn = 15;

    final attackAction = AttackVolcanicKernelAction(
      targetX: kKernelX,
      targetY: kKernelY,
      level: 3,
      selectedUnits: {
        UnitType.abyssAdmiral: 50,
        UnitType.domeBreaker: 200,
      },
      random: Random(0),
    );
    final attackResult = attackAction.execute(s.game, s.player);
    final entry = attackAction.makeHistoryEntry(
      s.game, s.player, attackResult, s.game.turn,
    );
    if (entry != null) s.player.addHistoryEntry(entry);

    final stats =
        const GameStatisticsCalculator().compute(s.game);
    expect(stats.turnsPlayed, 15);
    expect(stats.basesCaptured, greaterThanOrEqualTo(1));
  });
}
