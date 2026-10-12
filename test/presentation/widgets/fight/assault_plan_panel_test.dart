import 'package:abyss/domain/fight/assault/assault_plan.dart';
import 'package:abyss/domain/fight/assault/assault_target.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/fight/assault_check_row.dart';
import 'package:abyss/presentation/widgets/fight/assault_plan_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../domain/fight/assault/assault_test_helper.dart';

const _admiral = UnitType.abyssAdmiral;
const _guardian = UnitType.guardian;
const _harpoonist = UnitType.harpoonist;

AssaultPlan _plan(
  Map<UnitType, int> army, {
  AssaultTarget target = AssaultTarget.faille,
  Map<UnitType, int>? stock,
  int hq = 4,
  int maxHarpoonists = AssaultPlan.defaultMaxHarpoonists,
}) =>
    AssaultPlan.of(
      player: assaultPlayer(stock: stock ?? army, hq: hq),
      level: 1,
      target: target,
      army: army,
      maxHarpoonists: maxHarpoonists,
    );

Future<void> _pump(WidgetTester tester, AssaultPlan plan) =>
    tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: AssaultPlanPanel(plan: plan, level: 1),
        ),
      ),
    ));

AssaultCheckState _stateOf(WidgetTester tester, String title) => tester
    .widget<AssaultCheckRow>(find.widgetWithText(AssaultCheckRow, title))
    .state;

const _strong = {_admiral: 1, _guardian: 4, _harpoonist: 10};

void main() {
  testWidgets('titles the section', (tester) async {
    await _pump(tester, _plan(_strong));
    expect(find.text("PLAN D'ASSAUT"), findsOneWidget);
  });

  group('the admiral check', () {
    const title = "Un Amiral dans l'armée";

    testWidgets('is ok with the admirals sent', (tester) async {
      await _pump(tester, _plan(_strong));
      expect(_stateOf(tester, title), AssaultCheckState.ok);
      expect(find.text('1 Amiral au niveau 1'), findsOneWidget);
    });

    testWidgets('is missing when one waits on the level', (tester) async {
      await _pump(tester,
          _plan({_harpoonist: 10}, stock: {_admiral: 2, _harpoonist: 10}));
      expect(_stateOf(tester, title), AssaultCheckState.missing);
      expect(find.text('Ajoute-le : 2 Amiraux au niveau 1'), findsOneWidget);
    });

    testWidgets('tells where to recruit one when none', (tester) async {
      await _pump(tester, _plan({_harpoonist: 10}));
      expect(_stateOf(tester, title), AssaultCheckState.missing);
      expect(find.text('Recrute-en un à la Caserne niveau 2'),
          findsOneWidget);
    });
  });

  group('the cover check', () {
    const title = "L'Amiral est couvert";

    testWidgets('is ok with guardians', (tester) async {
      await _pump(tester, _plan(_strong));
      expect(_stateOf(tester, title), AssaultCheckState.ok);
      expect(find.text('4 Gardiens prennent les coups pour lui'),
          findsOneWidget);
    });

    testWidgets('warns without any guardian', (tester) async {
      await _pump(tester, _plan({_admiral: 1, _harpoonist: 30}));
      expect(_stateOf(tester, title), AssaultCheckState.warning);
      expect(find.text('Sans Gardien, il prend les coups le premier'),
          findsOneWidget);
    });
  });

  group('the army check and the gauge', () {
    const title = 'Armée suffisante';

    LinearProgressIndicator gauge(WidgetTester tester) =>
        tester.widget(find.byType(LinearProgressIndicator));

    testWidgets('are high for a strong army', (tester) async {
      await _pump(tester, _plan(_strong));
      expect(_stateOf(tester, title), AssaultCheckState.ok);
      expect(find.text('Élevées · 19 sur 20'), findsOneWidget);
      expect(gauge(tester).value, closeTo(0.95, 1e-9));
      expect(gauge(tester).color, AbyssColors.success);
    });

    testWidgets('are risky for a borderline army', (tester) async {
      await _pump(
          tester,
          _plan({_admiral: 1, _guardian: 4, _harpoonist: 34},
              target: AssaultTarget.cheminee));
      expect(_stateOf(tester, title), AssaultCheckState.warning);
      expect(find.text('Risquées · 13 sur 20'), findsOneWidget);
      expect(gauge(tester).color, AbyssColors.warning);
    });

    testWidgets('are low for a weak army', (tester) async {
      await _pump(tester, _plan({_admiral: 1, _harpoonist: 2}));
      expect(_stateOf(tester, title), AssaultCheckState.missing);
      expect(find.text('Trop faible : ajoute des unités'), findsOneWidget);
      expect(find.text('Faibles · 0 sur 20'), findsOneWidget);
      expect(gauge(tester).color, AbyssColors.error);
    });

    testWidgets('are low without an admiral', (tester) async {
      await _pump(tester, _plan({_harpoonist: 60}));
      expect(find.text("Sans Amiral, rien n'est pris"), findsOneWidget);
      expect(find.text('Faibles · 0 sur 20'), findsOneWidget);
    });
  });

  group('the next step', () {
    testWidgets('warns when the headquarters are too low', (tester) async {
      await _pump(tester, _plan(_strong));
      const title = 'Ensuite : Module de Descente';
      expect(_stateOf(tester, title), AssaultCheckState.warning);
      expect(find.text('Il demande le QG 5, tu es au QG 4'), findsOneWidget);
    });

    testWidgets('is ok when the headquarters allow it', (tester) async {
      await _pump(tester, _plan(_strong, hq: 5));
      expect(_stateOf(tester, 'Ensuite : Module de Descente'),
          AssaultCheckState.ok);
      expect(find.text('Ton QG 5 le permet déjà'), findsOneWidget);
    });

    testWidgets('is absent for the kernel', (tester) async {
      await _pump(tester,
          _plan(_strong, target: AssaultTarget.kernel, maxHarpoonists: 1));
      expect(find.textContaining('Ensuite'), findsNothing);
    });
  });

  group('the advice', () {
    testWidgets('names the escort and the harpoonists', (tester) async {
      await _pump(tester, _plan({_admiral: 1, _guardian: 4, _harpoonist: 2}));
      expect(find.text("Conseil : l'Amiral avec 4 gardiens, 10 harponneurs"),
          findsOneWidget);
    });

    testWidgets('advises harpoonists alone without guardians',
        (tester) async {
      await _pump(tester, _plan({_harpoonist: 2}, stock: const {}));
      expect(find.textContaining("Conseil : l'Amiral avec"), findsOneWidget);
      expect(find.textContaining('gardien'), findsNothing);
    });

    testWidgets('is absent when out of reach', (tester) async {
      await _pump(tester,
          _plan(_strong, target: AssaultTarget.kernel, maxHarpoonists: 1));
      expect(find.textContaining('Conseil'), findsNothing);
    });
  });
}
