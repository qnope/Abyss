import 'package:abyss/domain/objective/temporary/temporary_objective_kind.dart';
import 'package:abyss/presentation/extensions/temporary_objective_kind_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every temporary objective has a short French name', () {
    expect(TemporaryObjectiveKind.wreck.shortLabel, 'Épave');
    expect(TemporaryObjectiveKind.predators.shortLabel, 'Prédateurs');
  });
}
