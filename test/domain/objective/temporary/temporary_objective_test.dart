import 'package:abyss/domain/objective/temporary/temporary_objective.dart';
import 'package:abyss/domain/objective/temporary/temporary_objective_kind.dart';
import 'package:flutter_test/flutter_test.dart';

TemporaryObjective _wreck({int lastTurn = 17}) => TemporaryObjective(
  kind: TemporaryObjectiveKind.wreck,
  lastTurn: lastTurn,
);

void main() {
  group('TemporaryObjective', () {
    test('equal when its kind and last turn are', () {
      expect(_wreck(), _wreck());
      expect(_wreck().hashCode, _wreck().hashCode);
    });

    test('different as soon as one of them differs', () {
      expect(_wreck(), isNot(_wreck(lastTurn: 18)));
      expect(
        _wreck(),
        isNot(
          const TemporaryObjective(
            kind: TemporaryObjectiveKind.predators,
            lastTurn: 17,
          ),
        ),
      );
      expect(_wreck(), isNot('wreck'));
    });

    test('reads as its kind and last turn', () {
      expect(_wreck().toString(), 'TemporaryObjective(wreck, 17)');
    });
  });
}
