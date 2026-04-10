import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';

void main() {
  group('TransitionBase', () {
    test('constructs with required fields', () {
      final base = TransitionBase(
        type: TransitionBaseType.faille,
        name: 'Faille Alpha',
      );
      expect(base.type, TransitionBaseType.faille);
      expect(base.name, 'Faille Alpha');
      expect(base.capturedBy, isNull);
    });

    test('isCaptured is false when capturedBy is null', () {
      final base = TransitionBase(
        type: TransitionBaseType.faille,
        name: 'Faille Alpha',
      );
      expect(base.isCaptured, isFalse);
    });

    test('isCaptured is true when capturedBy is set', () {
      final base = TransitionBase(
        type: TransitionBaseType.cheminee,
        name: 'Cheminee Beta',
        capturedBy: 'player-1',
      );
      expect(base.isCaptured, isTrue);
    });

    test('difficulty is 4 for faille', () {
      final base = TransitionBase(
        type: TransitionBaseType.faille,
        name: 'F1',
      );
      expect(base.difficulty, 4);
    });

    test('difficulty is 5 for cheminee', () {
      final base = TransitionBase(
        type: TransitionBaseType.cheminee,
        name: 'C1',
      );
      expect(base.difficulty, 5);
    });

    test('targetLevel is 2 for faille', () {
      final base = TransitionBase(
        type: TransitionBaseType.faille,
        name: 'F1',
      );
      expect(base.targetLevel, 2);
    });

    test('targetLevel is 3 for cheminee', () {
      final base = TransitionBase(
        type: TransitionBaseType.cheminee,
        name: 'C1',
      );
      expect(base.targetLevel, 3);
    });
  });
}
