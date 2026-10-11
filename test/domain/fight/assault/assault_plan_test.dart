import 'package:abyss/domain/fight/assault/assault_chance.dart';
import 'package:abyss/domain/fight/assault/assault_plan.dart';
import 'package:abyss/domain/fight/assault/assault_target.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'assault_test_helper.dart';

const _admiral = UnitType.abyssAdmiral;
const _guardian = UnitType.guardian;
const _harpoonist = UnitType.harpoonist;

AssaultPlan _plan(Map<UnitType, int> army,
        {AssaultTarget target = AssaultTarget.faille,
        Map<UnitType, int> stock = const {},
        int hq = 1}) =>
    AssaultPlan.of(
      player: assaultPlayer(stock: stock, hq: hq),
      level: 1,
      target: target,
      army: army,
    );

void main() {
  group('the admiral', () {
    test('is present with at least one in the army', () {
      expect(_plan({_admiral: 1}).hasAdmiral, isTrue);
      expect(_plan({_admiral: 0, _harpoonist: 5}).hasAdmiral, isFalse);
    });

    test('counts the admirals the player has on the level', () {
      expect(_plan({}, stock: {_admiral: 2}).admiralsAvailable, 2);
      expect(_plan({}).admiralsAvailable, 0);
    });

    test('is covered by at least one guardian', () {
      expect(_plan({_admiral: 1, _guardian: 1}).admiralCovered, isTrue);
      expect(_plan({_admiral: 1, _harpoonist: 9}).admiralCovered, isFalse);
    });
  });

  group('the chance', () {
    test('is none without an admiral, without rehearsing', () {
      expect(_plan({_harpoonist: 60}).chance, AssaultChance.none);
    });

    test('is high for a strong army', () {
      final chance =
          _plan({_admiral: 1, _guardian: 4, _harpoonist: 40}).chance;

      expect(chance.rehearsals, AssaultPlan.rehearsals);
      expect(chance.rating, AssaultRating.high);
    });

    test('is low for a weak army', () {
      final chance = _plan({_admiral: 1, _harpoonist: 2}).chance;

      expect(chance.rating, AssaultRating.low);
    });

    test('fights the kernel guardians on the kernel', () {
      const army = {_admiral: 1, _guardian: 4, _harpoonist: 40};

      expect(_plan(army, target: AssaultTarget.kernel).chance.rating,
          AssaultRating.low);
    });

    test('is the same for the same input', () {
      const army = {_admiral: 1, _guardian: 1, _harpoonist: 12};

      expect(_plan(army).chance, _plan(Map.of(army)).chance);
    });
  });

  group('the next step', () {
    test('is the Module de descente after a Faille, HQ 5', () {
      final step = _plan({}, hq: 4).nextStep!;

      expect(step.requiredHq, 5);
      expect(step.currentHq, 4);
      expect(step.isReady, isFalse);
      expect(_plan({}, hq: 5).nextStep!.isReady, isTrue);
    });

    test('is the Capsule pressurisée after a Cheminée, HQ 8', () {
      final step = _plan({}, target: AssaultTarget.cheminee, hq: 8).nextStep!;

      expect(step.building, AssaultTarget.cheminee.passage);
      expect(step.requiredHq, 8);
      expect(step.isReady, isTrue);
    });

    test('is none after the kernel', () {
      expect(_plan({}, target: AssaultTarget.kernel).nextStep, isNull);
    });
  });
}
