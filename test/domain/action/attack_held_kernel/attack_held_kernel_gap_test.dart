import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/action_failure.dart';
import 'package:abyss/domain/action/upgrade_building_action.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/difficulty.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/kernel_war_helper.dart';

/// The human holds the kernel at [level]; it turned hot [hotAgo] turns
/// before and lost a siege [lostAgo] turns before (never when `null`).
KernelWar _humanKernel({int level = 7, int? hotAgo, int? lostAgo}) {
  final war =
      KernelWar(kernelLevel: level, humanHolds: true)
        ..game.turn = 40
        ..arm();
  final state = war.human.raidState;
  if (hotAgo != null) state.kernelHotTurn = war.game.turn - hotAgo;
  if (lostAgo != null) state.kernelSiegeLostTurn = war.game.turn - lostAgo;
  return war;
}

ActionFailure? _refusal(KernelWar war) =>
    war.strike(horde).validate(war.game, war.attacker).reason;

void main() {
  test('the harder the game, the closer the sieges of the kernel', () {
    expect(Difficulty.easy.kernelGap, 12);
    expect(Difficulty.normal.kernelGap, 10);
    expect(Difficulty.hard.kernelGap, 6);
  });

  test('a faction waits kernelGap turns after the kernel turned hot', () {
    final gap = _humanKernel().game.difficulty.kernelGap;

    expect(
      _refusal(_humanKernel(hotAgo: gap - 1)),
      ActionFailure.attackTooSoon,
    );
    expect(_refusal(_humanKernel(hotAgo: gap)), isNull);
  });

  test('a faction waits kernelGap turns after a siege the human lost', () {
    final gap = _humanKernel().game.difficulty.kernelGap;

    expect(
      _refusal(_humanKernel(level: 3, lostAgo: gap - 1)),
      ActionFailure.attackTooSoon,
    );
    expect(_refusal(_humanKernel(level: 3, lostAgo: gap)), isNull);
  });

  test('a legacy save, with no turn kept, has no gap', () {
    expect(_refusal(_humanKernel()), isNull);
  });

  test('the human attacking a faction kernel is not spaced', () {
    final war = KernelWar(kernelLevel: 7)..game.turn = 40;
    war.owner.raidState
      ..kernelHotTurn = 40
      ..kernelSiegeLostTurn = 40;
    war.put(war.human, 3, horde);

    expect(war.strike(horde).validate(war.game, war.human).reason, isNull);
  });

  group('upgrading the kernel', () {
    KernelWar rich(int level) {
      final war = _humanKernel(level: level);
      war.human.buildings[BuildingType.headquarters]!.level = 10;
      for (final r in war.human.resources.values) {
        r.amount = 1000000;
      }
      return war;
    }

    void upgrade(KernelWar war) {
      final result = ActionExecutor().execute(
        UpgradeBuildingAction(buildingType: BuildingType.volcanicKernel),
        war.game,
        war.human,
      );
      expect(result.isSuccess, isTrue, reason: '${result.reason}');
    }

    test('to the hot level dates the gap', () {
      final war = rich(6);

      upgrade(war);

      expect(war.kernelOf(war.human), 7);
      expect(war.human.raidState.kernelHotTurn, 40);
    });

    test('below or above the hot level leaves it alone', () {
      final low = rich(5);
      final high = rich(7);

      upgrade(low);
      upgrade(high);

      expect(low.human.raidState.kernelHotTurn, isNull);
      expect(high.human.raidState.kernelHotTurn, isNull);
    });
  });
}
