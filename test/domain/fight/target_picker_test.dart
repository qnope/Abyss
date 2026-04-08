import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/target_picker.dart';

Combatant _alive(String key, {CombatSide side = CombatSide.monster}) {
  return Combatant(
    side: side,
    typeKey: key,
    maxHp: 10,
    atk: 2,
    def: 1,
  );
}

Combatant _dead(String key, {CombatSide side = CombatSide.monster}) {
  final Combatant c = _alive(key, side: side);
  c.applyDamage(999);
  return c;
}

void main() {
  group('TargetPicker.pickRandom', () {
    test('single alive target is returned', () {
      final Combatant only = _alive('a');
      final List<Combatant> pool = <Combatant>[only, _dead('b'), _dead('c')];

      final Combatant? picked = TargetPicker.pickRandom(pool, Random(1));

      expect(picked, same(only));
    });

    test('returns null when all combatants are dead', () {
      final List<Combatant> pool = <Combatant>[_dead('a'), _dead('b')];

      expect(TargetPicker.pickRandom(pool, Random(1)), isNull);
    });

    test('never returns a dead combatant over 100 seeded rolls', () {
      final Combatant a = _alive('a');
      final Combatant b = _alive('b');
      final List<Combatant> pool = <Combatant>[_dead('x'), a, _dead('y'), b];
      final Random random = Random(7);

      for (int i = 0; i < 100; i++) {
        final Combatant? picked = TargetPicker.pickRandom(pool, random);
        expect(picked, isNotNull);
        expect(picked!.isAlive, isTrue);
      }
    });

    test('distribution is roughly uniform across alive combatants', () {
      final Combatant a = _alive('a');
      final Combatant b = _alive('b');
      final Combatant c = _alive('c');
      final List<Combatant> pool = <Combatant>[a, b, c];
      final Random random = Random(123);
      final Map<String, int> counts = <String, int>{'a': 0, 'b': 0, 'c': 0};

      for (int i = 0; i < 1000; i++) {
        final Combatant picked = TargetPicker.pickRandom(pool, random)!;
        counts[picked.typeKey] = counts[picked.typeKey]! + 1;
      }

      // Loose bounds: each bucket should be clearly non-empty and not dominate.
      for (final int count in counts.values) {
        expect(count, greaterThan(200));
        expect(count, lessThan(500));
      }
    });
  });
}
