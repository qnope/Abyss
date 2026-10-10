import 'package:abyss/domain/action/action_failure.dart';
import 'package:abyss/domain/action/action_result.dart';
import 'package:abyss/presentation/extensions/action_failure_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/l10n_fixtures.dart';

void main() {
  test('says in French why an action failed', () {
    expect(ActionFailure.notEnoughUnits.message(fr), 'Unités insuffisantes');
    expect(ActionFailure.mapNotGenerated.message(fr), 'Carte non générée');
    expect(ActionFailure.lairEmpty.message(fr), 'Repaire vide');
    expect(
      ActionFailure.notThisChoiceTurn.message(fr),
      "Ce n'est pas le tour de ce choix",
    );
  });

  test('says it in English and Spanish', () {
    expect(ActionFailure.notEnoughUnits.message(en), 'Not enough units');
    expect(
      ActionFailure.admiralRequired.message(en),
      'An Abyss Admiral is required',
    );
    expect(ActionFailure.notEnoughUnits.message(es), 'Unidades insuficientes');
    expect(
      ActionFailure.noScoutAvailable.message(es),
      'Ningún explorador disponible',
    );
  });

  test('every failure has its own text in each language', () {
    for (final l10n in [fr, en, es]) {
      final texts = {
        for (final failure in ActionFailure.values) failure.message(l10n),
      };
      expect(texts, hasLength(ActionFailure.values.length));
      expect(texts, everyElement(isNotEmpty));
    }
  });

  test('a failed result reads its reason, or a generic text without one', () {
    const failed = ActionResult.failure(ActionFailure.lairEmpty);
    expect(failed.failureMessage(en), 'Empty lair');
    expect(
      const ActionResult.success().failureMessage(fr),
      'Action impossible',
    );
    expect(const ActionResult.success().failureMessage(es), 'Acción imposible');
  });
}
