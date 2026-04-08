import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/fight/army_selection_screen.dart';
import 'package:abyss/presentation/screens/game/fight/fight_summary_screen.dart';

import '../../../../domain/action/fight_monster_action_helper.dart';
import '../../../../helpers/fake_game_repository.dart';
import '../../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  const MonsterLair lair = MonsterLair(
    difficulty: MonsterDifficulty.easy,
    unitCount: 1,
  );

  Widget buildApp({
    required FakeGameRepository repository,
    required VoidCallback onChanged,
    Map<UnitType, int> stock = const {UnitType.scout: 3, UnitType.harpoonist: 2},
  }) {
    final scenario = createFightScenario(stock: stock);
    return MaterialApp(
      home: ArmySelectionScreen(
        game: scenario.game,
        repository: repository,
        targetX: 1,
        targetY: 1,
        lair: lair,
        onChanged: onChanged,
      ),
    );
  }

  group('ArmySelectionScreen', () {
    testWidgets('lists unit types with count > 0', (tester) async {
      await tester.pumpWidget(buildApp(
        repository: FakeGameRepository(),
        onChanged: () {},
      ));
      await tester.pumpAndSettle();

      expect(find.text('Eclaireur'), findsOneWidget);
      expect(find.text('Harponneur'), findsOneWidget);
      expect(find.text('Gardien'), findsNothing);
    });

    testWidgets('hides unit types with count == 0', (tester) async {
      await tester.pumpWidget(buildApp(
        repository: FakeGameRepository(),
        onChanged: () {},
        stock: const {UnitType.scout: 2},
      ));
      await tester.pumpAndSettle();

      expect(find.text('Eclaireur'), findsOneWidget);
      expect(find.text('Harponneur'), findsNothing);
      expect(find.text('Briseur'), findsNothing);
    });

    testWidgets('launch button disabled when no units selected',
        (tester) async {
      await tester.pumpWidget(buildApp(
        repository: FakeGameRepository(),
        onChanged: () {},
      ));
      await tester.pumpAndSettle();

      final ElevatedButton button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Lancer le combat'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('tapping + enables the launch button', (tester) async {
      await tester.pumpWidget(buildApp(
        repository: FakeGameRepository(),
        onChanged: () {},
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pump();

      final ElevatedButton button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Lancer le combat'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('launch button saves and navigates to FightSummaryScreen',
        (tester) async {
      final repository = FakeGameRepository();
      int onChangedCalls = 0;
      await tester.pumpWidget(buildApp(
        repository: repository,
        onChanged: () => onChangedCalls++,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Lancer le combat'));
      await tester.pumpAndSettle();

      expect(repository.saveCallCount, 1);
      expect(onChangedCalls, 1);
      expect(find.byType(FightSummaryScreen), findsOneWidget);
    });

    testWidgets('Annuler pops without calling save', (tester) async {
      final repository = FakeGameRepository();
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (ctx) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  final scenario = createFightScenario(
                    stock: const {UnitType.scout: 2},
                  );
                  Navigator.of(ctx).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ArmySelectionScreen(
                        game: scenario.game,
                        repository: repository,
                        targetX: 1,
                        targetY: 1,
                        lair: lair,
                        onChanged: () {},
                      ),
                    ),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Préparer le combat'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Annuler'));
      await tester.pumpAndSettle();

      expect(find.text('Préparer le combat'), findsNothing);
      expect(repository.saveCallCount, 0);
    });
  });
}
