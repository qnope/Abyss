import 'package:abyss/domain/leviathan/leviathan_defence_advisor.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/game_screen_turn_helpers.dart';
import 'package:abyss/presentation/widgets/leviathan/leviathan_due_warning.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../domain/leviathan/leviathan_scene.dart';
import '../../../helpers/l10n_fixtures.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/post_attack_helper.dart';

PostWar _strikeTurn() {
  final war = leviathanScene();
  war.playUntil(war.strikeTurn);
  return war;
}

Future<void> _show(WidgetTester t, PostWar war) => t.pumpWidget(
  localizedApp(
    Scaffold(body: dueWarnings(fr, war.game, war.human) ?? const Text('-')),
  ),
);

void main() {
  test('none before the turn the guardians strike', () {
    final war = leviathanScene();
    war.playUntil(war.strikeTurn - 1);
    expect(LeviathanDueWarning.of(war.game, war.human), isNull);
  });

  testWidgets('warns when level 2 is empty', (t) async {
    await _show(t, _strikeTurn());
    expect(
      find.text(
        'Le Léviathan frappe ta Faille à la fin du tour, et aucun défenseur '
        "ne l'attend au niveau 2.",
      ),
      findsOneWidget,
    );
  });

  testWidgets('warns when level 2 is too weak', (t) async {
    final war = _strikeTurn();
    war.put(war.human, 2, {UnitType.harpoonist: 1});
    await _show(t, war);
    expect(
      find.text(
        'Le Léviathan frappe ta Faille à la fin du tour, et seulement 1 '
        "défenseur l'attend au niveau 2.",
      ),
      findsOneWidget,
    );
  });

  test('none once level 2 should hold', () {
    final war = _strikeTurn();
    final needed = LeviathanDefenceAdvisor.unitsFor(war.game, war.human, 2)!;
    war.put(war.human, 2, {UnitType.harpoonist: needed});
    expect(LeviathanDueWarning.of(war.game, war.human), isNull);
  });
}
