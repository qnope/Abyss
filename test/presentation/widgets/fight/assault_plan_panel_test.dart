import 'package:abyss/domain/fight/assault/assault_target.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/fight/assault_check_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'assault_plan_panel_helper.dart';

void main() {
  testWidgets('titles the section', (tester) async {
    await pump(tester, plan(strong));
    expect(find.text("PLAN D'ASSAUT"), findsOneWidget);
  });

  group('the admiral check', () {
    const title = "Un Amiral dans l'armée";

    testWidgets('is ok with the admirals sent', (tester) async {
      await pump(tester, plan(strong));
      expect(stateOf(tester, title), AssaultCheckState.ok);
      expect(find.text('1 Amiral au niveau 1'), findsOneWidget);
    });

    testWidgets('is missing when one waits on the level', (tester) async {
      await pump(tester,
          plan({harpoonist: 10}, stock: {admiral: 2, harpoonist: 10}));
      expect(stateOf(tester, title), AssaultCheckState.missing);
      expect(find.text('Ajoute-le : 2 Amiraux au niveau 1'), findsOneWidget);
    });

    testWidgets('tells where to recruit one when none', (tester) async {
      await pump(tester, plan({harpoonist: 10}));
      expect(stateOf(tester, title), AssaultCheckState.missing);
      expect(find.text('Recrute-en un à la Caserne niveau 2'),
          findsOneWidget);
    });
  });

  group('the cover check', () {
    const title = "L'Amiral est couvert";

    testWidgets('is ok with guardians', (tester) async {
      await pump(tester, plan(strong));
      expect(stateOf(tester, title), AssaultCheckState.ok);
      expect(find.text('4 Gardiens prennent les coups pour lui'),
          findsOneWidget);
    });

    testWidgets('warns without any guardian', (tester) async {
      await pump(tester, plan({admiral: 1, harpoonist: 30}));
      expect(stateOf(tester, title), AssaultCheckState.warning);
      expect(find.text('Sans Gardien, il prend les coups le premier'),
          findsOneWidget);
    });
  });

  group('the army check and the gauge', () {
    const title = 'Armée suffisante';

    LinearProgressIndicator gauge(WidgetTester tester) =>
        tester.widget(find.byType(LinearProgressIndicator));

    testWidgets('are high for a strong army', (tester) async {
      await pump(tester, plan(strong));
      expect(stateOf(tester, title), AssaultCheckState.ok);
      expect(find.text('Élevées · 19 sur 20'), findsOneWidget);
      expect(gauge(tester).value, closeTo(0.95, 1e-9));
      expect(gauge(tester).color, AbyssColors.success);
    });

    testWidgets('are risky for a borderline army', (tester) async {
      await pump(
          tester,
          plan({admiral: 1, guardian: 4, harpoonist: 34},
              target: AssaultTarget.cheminee));
      expect(stateOf(tester, title), AssaultCheckState.warning);
      expect(find.text('Risquées · 13 sur 20'), findsOneWidget);
      expect(gauge(tester).color, AbyssColors.warning);
    });

    testWidgets('are low for a weak army', (tester) async {
      await pump(tester, plan({admiral: 1, harpoonist: 2}));
      expect(stateOf(tester, title), AssaultCheckState.missing);
      expect(find.text('Trop faible : ajoute des unités'), findsOneWidget);
      expect(find.text('Faibles · 0 sur 20'), findsOneWidget);
      expect(gauge(tester).color, AbyssColors.error);
    });

    testWidgets('are low without an admiral', (tester) async {
      await pump(tester, plan({harpoonist: 60}));
      expect(find.text("Sans Amiral, rien n'est pris"), findsOneWidget);
      expect(find.text('Faibles · 0 sur 20'), findsOneWidget);
    });
  });
}
