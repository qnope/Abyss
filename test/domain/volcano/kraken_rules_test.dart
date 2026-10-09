import 'dart:math';

import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/combatant_builder.dart';
import 'package:abyss/domain/fight/monster_rules.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/volcano/magma_rampart.dart';
import 'package:abyss/domain/volcano/volcano_wave_factory.dart';
import 'package:flutter_test/flutter_test.dart';

Combatant _unit() => Combatant(
  side: CombatSide.player,
  typeKey: 'harpoonist',
  maxHp: 10,
  atk: 3,
  def: 1,
);

void main() {
  final kraken = CombatantBuilder.monsterCombatantsFrom(
    VolcanoWaveFactory.fromKernelLevel(1),
  ).first;

  test('krakens fight as bosses', () {
    expect(kraken.isBoss, isTrue);
    expect(MonsterFamily.kraken.isBoss, isTrue);
  });

  test('Étreinte: a kraken hit strikes a second defender', () {
    final target = _unit();
    final other = _unit();
    final second =
        MonsterRules.secondTarget(kraken, target, [target, other], Random(1));
    expect(second, same(other));
  });

  test('no second strike when the target stands alone', () {
    final target = _unit();
    expect(MonsterRules.embraceTarget(kraken, target, [target], Random(1)),
        isNull);
  });

  test('the kraken never shows up in lairs or base raids', () {
    for (final level in [1, 2, 3]) {
      expect(MonsterFamily.availableAt(level), isNot(contains(MonsterFamily.kraken)));
    }
  });

  test('the magma rampart grows with the kernel', () {
    expect(MagmaRampart.combatantFor(0), isNull);
    final low = MagmaRampart.combatantFor(1)!;
    final high = MagmaRampart.combatantFor(9)!;
    expect(high.maxHp, greaterThan(low.maxHp));
    expect(high.atk, greaterThan(low.atk));
  });
}
