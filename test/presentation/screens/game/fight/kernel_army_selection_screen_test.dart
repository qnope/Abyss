import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/fight/kernel_army_selection_screen.dart';
import 'package:abyss/presentation/screens/game/fight/kernel_fight_summary_screen.dart';

import '../../../../domain/action/fight_monster_action_helper.dart';
import '../../../../helpers/fake_game_repository.dart';
import '../../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Widget buildApp({
    required FakeGameRepository repository,
    required VoidCallback onChanged,
    Map<UnitType, int> stock = const {
      UnitType.abyssAdmiral: 1,
      UnitType.scout: 3,
    },
  }) {
    final scenario = createFightScenario(
      stock: stock,
      content: CellContentType.volcanicKernel,
      withLair: false,
    );
    return MaterialApp(
      home: KernelArmySelectionScreen(
        game: scenario.game,
        repository: repository,
        targetX: 1,
        targetY: 1,
        level: 1,
        onChanged: onChanged,
      ),
    );
  }

  group('KernelArmySelectionScreen', () {
    testWidgets('displays Assaut: Noyau Volcanique title', (tester) async {
      await tester.pumpWidget(buildApp(
        repository: FakeGameRepository(),
        onChanged: () {},
      ));
      await tester.pumpAndSettle();

      expect(find.text('Assaut: Noyau Volcanique'), findsOneWidget);
    });

    testWidgets('admiral required warning shown when no admiral selected',
        (tester) async {
      await tester.pumpWidget(buildApp(
        repository: FakeGameRepository(),
        onChanged: () {},
        stock: const {UnitType.abyssAdmiral: 1, UnitType.scout: 3},
      ));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Un Amiral des Abysses est requis pour lancer l\'assaut',
        ),
        findsOneWidget,
      );
    });

    testWidgets('launch button disabled when no units selected',
        (tester) async {
      await tester.pumpWidget(buildApp(
        repository: FakeGameRepository(),
        onChanged: () {},
      ));
      await tester.pumpAndSettle();

      final ElevatedButton button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Lancer l\'assaut'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('launch button disabled when no admiral', (tester) async {
      await tester.pumpWidget(buildApp(
        repository: FakeGameRepository(),
        onChanged: () {},
        stock: const {UnitType.scout: 3},
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pump();

      final ElevatedButton button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Lancer l\'assaut'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('launch navigates to KernelFightSummaryScreen',
        (tester) async {
      final repository = FakeGameRepository();
      int calls = 0;
      await tester.pumpWidget(buildApp(
        repository: repository,
        onChanged: () => calls++,
        stock: const {UnitType.abyssAdmiral: 1, UnitType.scout: 3},
      ));
      await tester.pumpAndSettle();

      // Select the admiral (second row after scout)
      await tester.tap(find.byIcon(Icons.add).last);
      await tester.pump();

      final Finder launchButton =
          find.widgetWithText(ElevatedButton, 'Lancer l\'assaut');
      await tester.ensureVisible(launchButton);
      await tester.pumpAndSettle();
      await tester.tap(launchButton);
      await tester.pumpAndSettle();

      expect(repository.saveCallCount, 1);
      expect(calls, 1);
      expect(find.byType(KernelFightSummaryScreen), findsOneWidget);
    });
  });
}
