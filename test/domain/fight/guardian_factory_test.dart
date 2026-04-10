import 'package:flutter_test/flutter_test.dart';

import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/guardian_factory.dart';
import 'package:abyss/domain/map/transition_base_type.dart';

void main() {
  group('GuardianFactory', () {
    group('forFaille', () {
      test('returns 6 combatants (1 boss + 5 escorts)', () {
        final combatants = GuardianFactory.forFaille();

        expect(combatants, hasLength(6));
      });

      test('first combatant is the boss', () {
        final combatants = GuardianFactory.forFaille();
        final boss = combatants.first;

        expect(boss.isBoss, isTrue);
        expect(boss.typeKey, 'leviathan');
        expect(boss.maxHp, 100);
        expect(boss.atk, 15);
        expect(boss.def, 10);
        expect(boss.side, CombatSide.monster);
      });

      test('escorts are not bosses', () {
        final combatants = GuardianFactory.forFaille();
        final escorts = combatants.skip(1).toList();

        expect(escorts, hasLength(5));
        for (final e in escorts) {
          expect(e.isBoss, isFalse);
          expect(e.typeKey, 'sentinelle');
          expect(e.maxHp, 30);
          expect(e.atk, 8);
          expect(e.def, 5);
          expect(e.side, CombatSide.monster);
        }
      });
    });

    group('forCheminee', () {
      test('returns 9 combatants (1 boss + 8 escorts)', () {
        final combatants = GuardianFactory.forCheminee();

        expect(combatants, hasLength(9));
      });

      test('first combatant is the boss', () {
        final combatants = GuardianFactory.forCheminee();
        final boss = combatants.first;

        expect(boss.isBoss, isTrue);
        expect(boss.typeKey, 'titanVolcanique');
        expect(boss.maxHp, 200);
        expect(boss.atk, 25);
        expect(boss.def, 15);
        expect(boss.side, CombatSide.monster);
      });

      test('escorts are not bosses', () {
        final combatants = GuardianFactory.forCheminee();
        final escorts = combatants.skip(1).toList();

        expect(escorts, hasLength(8));
        for (final e in escorts) {
          expect(e.isBoss, isFalse);
          expect(e.typeKey, 'golemMagma');
          expect(e.maxHp, 50);
          expect(e.atk, 12);
          expect(e.def, 8);
          expect(e.side, CombatSide.monster);
        }
      });
    });

    group('forType', () {
      test('dispatches faille', () {
        final combatants =
            GuardianFactory.forType(TransitionBaseType.faille);

        expect(combatants, hasLength(6));
        expect(combatants.first.typeKey, 'leviathan');
      });

      test('dispatches cheminee', () {
        final combatants =
            GuardianFactory.forType(TransitionBaseType.cheminee);

        expect(combatants, hasLength(9));
        expect(combatants.first.typeKey, 'titanVolcanique');
      });
    });
  });
}
