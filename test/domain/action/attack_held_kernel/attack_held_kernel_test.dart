import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/action_failure.dart';
import 'package:abyss/domain/action/attack_base_result.dart';
import 'package:abyss/domain/action/garrison_kernel_action.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/game/victory_checker.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/kernel_war_helper.dart';

AttackBaseResult _run(KernelWar war, [Map<UnitType, int> army = horde]) =>
    ActionExecutor().execute(war.strike(army), war.game, war.attacker)
        as AttackBaseResult;

void main() {
  group('a won attack on a held kernel', () {
    test('lowers the kernel by one level and leaves it to its owner', () {
      final war = KernelWar(kernelLevel: 3)..arm()..garrison(smallGarrison);

      final result = _run(war);

      expect(result.victory, isTrue);
      expect(war.kernelOf(war.owner), 2);
      expect(war.holder, war.owner.id);
    });

    test('gives the kernel to the attacker when it falls to level 0', () {
      final war = KernelWar(kernelLevel: 1)..arm()..garrison(smallGarrison);

      _run(war);

      expect(war.kernelOf(war.owner), 0);
      expect(war.holder, war.attacker.id);
    });

    test('loses the garrison of the old owner with the kernel', () {
      final war = KernelWar(kernelLevel: 1)..arm()..garrison(smallGarrison);

      _run(war);

      expect(KernelGarrison.sizeOf(war.owner), 0);
    });

    test('an owner at level 0 without garrison loses it at once', () {
      final war = KernelWar(kernelLevel: 0)..arm();

      final result = _run(war);

      expect(result.victory, isTrue);
      expect(war.holder, war.attacker.id);
    });

    test('pillages nothing and leaves the rampart and headquarters', () {
      final war = KernelWar(kernelLevel: 2)..arm()..garrison(smallGarrison);
      final hq = war.owner.buildings[BuildingType.headquarters]!.level;

      final result = _run(war);

      expect(result.damage.pillaged, isEmpty);
      expect(war.owner.buildings[BuildingType.headquarters]!.level, hq);
    });
  });

  group('the defence of a held kernel', () {
    test('is the garrison and the magma rampart', () {
      final war = KernelWar(kernelLevel: 4)..arm()..garrison(fortress);

      final result = _run(war);

      expect(result.defence.engaged, fortress);
      expect(result.victory, isFalse);
    });

    test('the magma rampart alone resists a small army', () {
      final war = KernelWar(kernelLevel: 10)
        ..arm({UnitType.harpoonist: 4});

      final result = _run(war, {UnitType.harpoonist: 4});

      expect(result.victory, isFalse);
      expect(war.kernelOf(war.owner), 10);
      expect(war.holder, war.owner.id);
    });

    test('a lost attack sends the survivors of the garrison back', () {
      final war = KernelWar(kernelLevel: 4)..arm({UnitType.harpoonist: 5});
      war.garrison(fortress);

      _run(war, {UnitType.harpoonist: 5});

      expect(war.count(war.owner, KernelGarrison.stockKey, UnitType.guardian),
          greaterThan(0));
    });

    test('the units on the volcano level of the owner do not defend', () {
      final war = KernelWar(kernelLevel: 0)..arm();
      war.put(war.owner, KernelGarrison.volcanoLevel, fortress);

      expect(_run(war).victory, isTrue);
    });

    test('the army leaves the volcano level and comes back', () {
      final war = KernelWar(kernelLevel: 4)..arm()..garrison(fortress);

      _run(war);

      expect(war.count(war.attacker, KernelGarrison.volcanoLevel,
          UnitType.harpoonist), lessThan(80));
    });
  });

  group('the refusals', () {
    ActionFailure? why(KernelWar war, [Map<UnitType, int> army = horde]) =>
        war.strike(army).validate(war.game, war.attacker).reason;

    test('a kernel nobody holds is attacked through its guardians', () {
      final war = KernelWar()..arm();
      war.holder;
      final map = war.game.levels[3]!;
      map.setCell(war.at.x, war.at.y,
          map.cellAt(war.at.x, war.at.y).copyWith(collectedBy: null));

      expect(why(war), ActionFailure.kernelNotCaptured);
    });

    test('one cannot attack its own kernel', () {
      final war = KernelWar()..arm();
      final map = war.game.levels[3]!;
      map.setCell(war.at.x, war.at.y,
          map.cellAt(war.at.x, war.at.y).copyWith(collectedBy: war.attacker.id));

      expect(why(war), ActionFailure.cannotAttackSelf);
    });

    test('nobody attacks before the first raid', () {
      final war = KernelWar()..arm();
      war.game.turn = 3;

      expect(why(war), ActionFailure.attackTooEarly);
    });

    test('the army must stand on the volcano level', () {
      final war = KernelWar();

      expect(why(war), ActionFailure.notEnoughUnits);
      expect(why(war, const {}), ActionFailure.noUnitSelected);
    });

    test('the human must have seen the kernel', () {
      final war = KernelWar();
      war.put(war.human, 3, horde);
      war.human.revealedCellsPerLevel[3]!.clear();

      expect(
        war.strike(horde).validate(war.game, war.human).reason,
        ActionFailure.baseNotRevealed,
      );
    });
  });

  group('a kernel just taken', () {
    test('takes no garrison until it is built to level 1', () {
      final war = KernelWar(kernelLevel: 1)..arm()..garrison(smallGarrison);
      _run(war);
      war.put(war.attacker, 3, {UnitType.guardian: 2});

      final result = GarrisonKernelAction(
        selectedUnits: {UnitType.guardian: 2},
      ).validate(war.game, war.attacker);

      expect(result.reason, ActionFailure.kernelNotBuilt);
    });

    test('takes its garrison once the kernel stands at level 1', () {
      final war = KernelWar(kernelLevel: 1)..arm()..garrison(smallGarrison);
      _run(war);
      war.attacker.buildings[BuildingType.volcanicKernel]!.level = 1;
      war.put(war.attacker, 3, {UnitType.guardian: 2});

      final result = GarrisonKernelAction(
        selectedUnits: {UnitType.guardian: 2},
      ).validate(war.game, war.attacker);

      expect(result.isSuccess, isTrue);
    });
  });

  group('the history', () {
    test('both sides keep the assault with the kernel levels', () {
      final war = KernelWar(kernelLevel: 3)..arm()..garrison(smallGarrison);

      _run(war);

      final mine = war.attacker.historyEntries.whereType<BaseAssaultEntry>();
      final theirs = war.owner.historyEntries.whereType<BaseAssaultEntry>();
      expect(mine.single.defending, isFalse);
      expect(theirs.single.defending, isTrue);
      expect(mine.single.postName, 'volcanicKernel');
      expect(mine.single.rampartBefore, 3);
      expect(mine.single.rampartAfter, 2);
    });
  });

  test('a faction that raises the kernel to level 10 wins the game', () {
    final war = KernelWar(kernelLevel: 10);

    expect(VictoryChecker.check(war.game), GameStatus.defeat);
  });
}
