import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/presentation/widgets/map/monster_lair_sheet.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Widget buildOpener({
    required MonsterLair lair,
    required VoidCallback onPrepareFight,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showMonsterLairSheet(
              context,
              targetX: 1,
              targetY: 2,
              lair: lair,
              onPrepareFight: onPrepareFight,
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
  }

  Future<void> openSheet(WidgetTester tester) async {
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  group('MonsterLairSheet', () {
    testWidgets('renders difficulty, level, unit count and stats',
        (tester) async {
      await tester.pumpWidget(buildOpener(
        lair: const MonsterLair(
          difficulty: MonsterDifficulty.medium,
          unitCount: 4,
        ),
        onPrepareFight: () {},
      ));
      await openSheet(tester);
      expect(find.text('Rôdeurs (1, 2)'), findsOneWidget);
      expect(find.text('Moyen'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('4 monstres'), findsOneWidget);
      expect(find.text('20 / 5 / 2'), findsOneWidget);
    });

    testWidgets('shows the family, its rule and its weakness',
        (tester) async {
      await tester.pumpWidget(buildOpener(
        lair: const MonsterLair(
          difficulty: MonsterDifficulty.medium,
          unitCount: 50,
          family: MonsterFamily.hunter,
        ),
        onPrepareFight: () {},
      ));
      await openSheet(tester);
      expect(find.text('Chasseurs (1, 2)'), findsOneWidget);
      expect(find.text('50 Calmars-chasseurs'), findsOneWidget);
      expect(find.text('16 / 10 / 2'), findsOneWidget);
      expect(find.textContaining('Traque'), findsOneWidget);
      expect(find.text('Faible contre : Gardiens'), findsOneWidget);
    });

    testWidgets('renders stats for hard difficulty', (tester) async {
      await tester.pumpWidget(buildOpener(
        lair: const MonsterLair(
          difficulty: MonsterDifficulty.hard,
          unitCount: 6,
        ),
        onPrepareFight: () {},
      ));
      await openSheet(tester);
      expect(find.text('Difficile'), findsOneWidget);
      expect(find.text('35 / 8 / 3'), findsOneWidget);
    });

    testWidgets('tapping Préparer le combat invokes callback once',
        (tester) async {
      var callCount = 0;
      await tester.pumpWidget(buildOpener(
        lair: const MonsterLair(
          difficulty: MonsterDifficulty.easy,
          unitCount: 2,
        ),
        onPrepareFight: () => callCount++,
      ));
      await openSheet(tester);
      await tester.tap(find.text('Préparer le combat'));
      await tester.pumpAndSettle();
      expect(callCount, 1);
      expect(find.text('Préparer le combat'), findsNothing);
    });

    testWidgets('tapping Annuler pops without calling callback',
        (tester) async {
      var callCount = 0;
      await tester.pumpWidget(buildOpener(
        lair: const MonsterLair(
          difficulty: MonsterDifficulty.easy,
          unitCount: 2,
        ),
        onPrepareFight: () => callCount++,
      ));
      await openSheet(tester);
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(callCount, 0);
      expect(find.text('Annuler'), findsNothing);
    });
  });
}
