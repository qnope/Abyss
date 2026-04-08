import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/turn_order.dart';

Combatant _alive(String key, CombatSide side) {
  return Combatant(
    side: side,
    typeKey: key,
    maxHp: 10,
    atk: 2,
    def: 1,
  );
}

Combatant _dead(String key, CombatSide side) {
  final Combatant c = _alive(key, side);
  c.applyDamage(999);
  return c;
}

void main() {
  group('TurnOrder.shuffle', () {
    test('contains every alive combatant from both sides exactly once', () {
      final Combatant p1 = _alive('p1', CombatSide.player);
      final Combatant p2 = _alive('p2', CombatSide.player);
      final Combatant m1 = _alive('m1', CombatSide.monster);
      final Combatant m2 = _alive('m2', CombatSide.monster);

      final List<Combatant> order = TurnOrder.shuffle(
        <Combatant>[p1, p2],
        <Combatant>[m1, m2],
        Random(1),
      );

      expect(order.length, 4);
      expect(order.toSet(), <Combatant>{p1, p2, m1, m2});
    });

    test('excludes dead combatants from both sides', () {
      final Combatant p1 = _alive('p1', CombatSide.player);
      final Combatant pDead = _dead('pDead', CombatSide.player);
      final Combatant m1 = _alive('m1', CombatSide.monster);
      final Combatant mDead = _dead('mDead', CombatSide.monster);

      final List<Combatant> order = TurnOrder.shuffle(
        <Combatant>[p1, pDead],
        <Combatant>[m1, mDead],
        Random(2),
      );

      expect(order.length, 2);
      expect(order.toSet(), <Combatant>{p1, m1});
      expect(order.contains(pDead), isFalse);
      expect(order.contains(mDead), isFalse);
    });

    test('orders differ between Random(42) and Random(43)', () {
      List<String> keysFor(int seed) {
        final Combatant p1 = _alive('p1', CombatSide.player);
        final Combatant p2 = _alive('p2', CombatSide.player);
        final Combatant p3 = _alive('p3', CombatSide.player);
        final Combatant m1 = _alive('m1', CombatSide.monster);
        final Combatant m2 = _alive('m2', CombatSide.monster);
        final Combatant m3 = _alive('m3', CombatSide.monster);

        return TurnOrder.shuffle(
          <Combatant>[p1, p2, p3],
          <Combatant>[m1, m2, m3],
          Random(seed),
        ).map((Combatant c) => c.typeKey).toList();
      }

      expect(keysFor(42), isNot(equals(keysFor(43))));
    });

    test('ordering is deterministic given a seeded random', () {
      List<String> keysFor() {
        final Combatant p1 = _alive('p1', CombatSide.player);
        final Combatant p2 = _alive('p2', CombatSide.player);
        final Combatant m1 = _alive('m1', CombatSide.monster);
        final Combatant m2 = _alive('m2', CombatSide.monster);

        return TurnOrder.shuffle(
          <Combatant>[p1, p2],
          <Combatant>[m1, m2],
          Random(99),
        ).map((Combatant c) => c.typeKey).toList();
      }

      expect(keysFor(), equals(keysFor()));
    });
  });
}
