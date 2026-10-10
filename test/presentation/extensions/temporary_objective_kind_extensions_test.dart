import 'package:abyss/domain/objective/temporary/temporary_objective.dart';
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

  test('titles a temporary objective in each language', () {
    const wreck = TemporaryObjective(
      kind: TemporaryObjectiveKind.wreck,
      lastTurn: 17,
    );
    const predators = TemporaryObjective(
      kind: TemporaryObjectiveKind.predators,
      lastTurn: 12,
    );
    expect(
      wreck.displayTitle(fr),
      "Fouille l'épave d'ici la fin du tour 17",
    );
    expect(wreck.displayTitle(en), 'Search the wreck by the end of turn 17');
    expect(predators.displayTitle(fr), 'Repousse le banc de prédateurs');
    expect(predators.displayTitle(es), 'Repele el banco de depredadores');
  });
}
