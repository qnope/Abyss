import 'dart:math';

import 'package:abyss/domain/fight/casualty_calculator.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:flutter_test/flutter_test.dart';

Combatant _c(String key) => Combatant(
      side: CombatSide.player,
      typeKey: key,
      maxHp: 10,
      atk: 1,
      def: 1,
    );

List<Combatant> _many(int n) =>
    <Combatant>[for (var i = 0; i < n; i++) _c('u$i')];

void main() {
  group('CasualtyCalculator.woundedProbability', () {
    test('returns 0.8 at pctLost = 0.0', () {
      expect(CasualtyCalculator.woundedProbability(0.0), 0.8);
    });

    test('returns 0.8 at pctLost = 0.5', () {
      expect(CasualtyCalculator.woundedProbability(0.5), 0.8);
    });

    test('returns ~0.5 at midpoint pctLost = 0.65', () {
      expect(
        CasualtyCalculator.woundedProbability(0.65),
        closeTo(0.5, 1e-9),
      );
    });

    test('returns 0.2 at pctLost = 0.8', () {
      expect(CasualtyCalculator.woundedProbability(0.8), 0.2);
    });

    test('returns 0.2 at pctLost = 1.0', () {
      expect(CasualtyCalculator.woundedProbability(1.0), 0.2);
    });
  });

  group('CasualtyCalculator.partition', () {
    test('empty input produces empty wounded and dead lists', () {
      final calc = CasualtyCalculator(random: Random(0));
      final split = calc.partition(const <Combatant>[], 0.5);
      expect(split.wounded, isEmpty);
      expect(split.dead, isEmpty);
    });

    test('pctLost = 0.5 yields wounded count between 70 and 90 of 100', () {
      final calc = CasualtyCalculator(random: Random(0));
      final split = calc.partition(_many(100), 0.5);
      expect(split.wounded.length + split.dead.length, 100);
      expect(split.wounded.length, greaterThanOrEqualTo(70));
      expect(split.wounded.length, lessThanOrEqualTo(90));
    });

    test('pctLost = 0.9 yields wounded count between 10 and 30 of 100', () {
      final calc = CasualtyCalculator(random: Random(0));
      final split = calc.partition(_many(100), 0.9);
      expect(split.wounded.length + split.dead.length, 100);
      expect(split.wounded.length, greaterThanOrEqualTo(10));
      expect(split.wounded.length, lessThanOrEqualTo(30));
    });

    test('same seed and inputs yield identical partition', () {
      final inputA = _many(50);
      final inputB = _many(50);
      final a = CasualtyCalculator(random: Random(123)).partition(inputA, 0.6);
      final b = CasualtyCalculator(random: Random(123)).partition(inputB, 0.6);
      expect(a.wounded.length, b.wounded.length);
      expect(a.dead.length, b.dead.length);
      final aWoundedKeys = a.wounded.map((c) => c.typeKey).toList();
      final bWoundedKeys = b.wounded.map((c) => c.typeKey).toList();
      expect(aWoundedKeys, bWoundedKeys);
    });
  });
}
