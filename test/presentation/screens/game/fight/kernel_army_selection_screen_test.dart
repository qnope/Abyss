import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/fight/kernel_army_selection_screen.dart';
import 'package:abyss/domain/action/attack_volcanic_kernel_result.dart';

import '../../../../domain/action/fight_monster_action_helper.dart';
import '../../../../helpers/fake_game_repository.dart';
import '../../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Widget buildApp({
    required FakeGameRepository repository,
    required VoidCallback onChanged,
    ValueChanged<AttackVolcanicKernelResult?>? onResult,
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
    final screen = KernelArmySelectionScreen(
      game: scenario.game,
      repository: repository,
      targetX: 1,
      targetY: 1,
      level: 1,
      onChanged: onChanged,
    );
    if (onResult == null) return MaterialApp(home: screen);
    return MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async => onResult(await Navigator.of(context)
              .push<AttackVolcanicKernelResult>(
                  MaterialPageRoute(builder: (_) => screen))),
          child: const Text('go'),
        ),
      ),
    );
  }

  group('KernelArmySelectionScreen', () {
    testWidgets('displays Assaut : Noyau Volcanique title', (tester) async {
      await tester.pumpWidget(buildApp(
        repository: FakeGameRepository(),
        onChanged: () {},
      ));
      await tester.pumpAndSettle();

      expect(find.text('Assaut : Noyau Volcanique'), findsOneWidget);
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

    testWidgets('shows the assault plan, updated at each unit added',
        (tester) async {
      await tester.pumpWidget(buildApp(
        repository: FakeGameRepository(),
        onChanged: () {},
      ));
      await tester.pumpAndSettle();
      expect(find.text("PLAN D'ASSAUT"), findsOneWidget);
      expect(find.text('Ajoute-le : 1 Amiral au niveau 1'), findsOneWidget);
      expect(find.textContaining('Ensuite'), findsNothing);

      await tester.tap(find.byIcon(Icons.add).last);
      await tester.pumpAndSettle();
      expect(find.text('1 Amiral au niveau 1'), findsOneWidget);
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

    testWidgets('launch settles the assault and pops with its result',
        (tester) async {
      final repository = FakeGameRepository();
      int calls = 0;
      AttackVolcanicKernelResult? result;
      await tester.pumpWidget(buildApp(
        repository: repository,
        onChanged: () => calls++,
        onResult: (r) => result = r,
        stock: const {UnitType.abyssAdmiral: 1, UnitType.scout: 3},
      ));
      await tester.tap(find.text('go'));
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
      expect(find.byType(KernelArmySelectionScreen), findsNothing);
      expect(result?.isSuccess, isTrue);
      expect(result?.sent, {UnitType.abyssAdmiral: 1});
    });
  });
}
