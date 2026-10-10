import 'package:abyss/domain/objective/temporary/temporary_objective.dart';
import 'package:abyss/domain/objective/temporary/temporary_objective_kind.dart';
import 'package:flutter_test/flutter_test.dart';

TemporaryObjective _wreck({String title = 'Fouille', int lastTurn = 17}) =>
    TemporaryObjective(
      kind: TemporaryObjectiveKind.wreck,
      title: title,
      lastTurn: lastTurn,
    );

void main() {
  group('TemporaryObjective', () {
    test('equal when its kind, title and last turn are', () {
      expect(_wreck(), _wreck());
      expect(_wreck().hashCode, _wreck().hashCode);
    });

    test('different as soon as one of them differs', () {
      expect(_wreck(), isNot(_wreck(title: 'Autre')));
      expect(_wreck(), isNot(_wreck(lastTurn: 18)));
      expect(
        _wreck(),
        isNot(
          const TemporaryObjective(
            kind: TemporaryObjectiveKind.predators,
            title: 'Fouille',
            lastTurn: 17,
          ),
        ),
      );
      expect(_wreck(), isNot('Fouille'));
    });

    test('reads as its kind, title and last turn', () {
      expect(_wreck().toString(), 'TemporaryObjective(wreck, Fouille, 17)');
    });
  });
}
