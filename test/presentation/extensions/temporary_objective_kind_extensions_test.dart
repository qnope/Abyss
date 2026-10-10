import 'package:abyss/domain/objective/temporary/temporary_objective_kind.dart';
import 'package:abyss/presentation/extensions/temporary_objective_kind_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/l10n_fixtures.dart';

void main() {
  test('every temporary objective has a short French name', () {
    expect(TemporaryObjectiveKind.wreck.shortLabel(fr), 'Épave');
    expect(TemporaryObjectiveKind.predators.shortLabel(fr), 'Prédateurs');
  });

  test('every temporary objective has a short name in English and Spanish',
      () {
    expect(TemporaryObjectiveKind.wreck.shortLabel(en), 'Wreck');
    expect(TemporaryObjectiveKind.predators.shortLabel(es), 'Depredadores');
  });
}
