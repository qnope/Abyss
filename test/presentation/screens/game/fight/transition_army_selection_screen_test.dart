import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/fight/unit_quantity_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../integration/transition_test_helper.dart';
import 'transition_army_selection_helper.dart';

void main() {
  mockSvgs();

  late ArmySelectionHarness screen;

  setUp(() => screen = ArmySelectionHarness());

  group('TransitionArmySelectionScreen', () {
    testWidgets('shows base name and a row per unit in stock',
        (tester) async {
      await screen.pump(tester, buildTransitionScenario().game);
      expect(find.text('Assaut : Faille Alpha'), findsOneWidget);
      expect(find.byType(UnitQuantityRow), findsNWidgets(3));
    });

    testWidgets('launch disabled and warning shown without admiral',
        (tester) async {
      await screen.pump(tester, buildTransitionScenario().game);
      expect(find.text(admiralWarning), findsOneWidget);
      expect(launchButton(tester).onPressed, isNull);

      await select(tester, UnitType.domeBreaker, 5);
      expect(launchButton(tester).onPressed, isNull);
    });

    testWidgets('selecting the admiral enables launch', (tester) async {
      await screen.pump(tester, buildTransitionScenario().game);
      await addAdmiral(tester);
      expect(find.text(admiralWarning), findsNothing);
      expect(launchButton(tester).onPressed, isNotNull);
    });

    testWidgets('shows the assault plan, updated at each unit added',
        (tester) async {
      await screen.pump(tester, buildTransitionScenario().game);
      expect(find.text("PLAN D'ASSAUT"), findsOneWidget);
      expect(find.text('Ajoute-le : 1 Amiral au niveau 1'), findsOneWidget);

      await addAdmiral(tester);
      expect(find.text('1 Amiral au niveau 1'), findsOneWidget);
      expect(find.text('Ajoute-le : 1 Amiral au niveau 1'), findsNothing);
    });

    testWidgets('keeps the launch button on screen on a small phone',
        (tester) async {
      await screen.pump(tester, buildTransitionScenario().game);
      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(ElevatedButton, 'Lancer l\'assaut').hitTestable(),
        findsOneWidget,
      );
    });
  });
}
