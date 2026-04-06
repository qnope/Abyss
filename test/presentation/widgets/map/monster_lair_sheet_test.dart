import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/presentation/widgets/map/monster_lair_sheet.dart';

void main() {
  Widget buildOpener({required MonsterDifficulty difficulty}) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showMonsterLairSheet(
              context,
              targetX: 1,
              targetY: 2,
              difficulty: difficulty,
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
  }

  group('MonsterLairSheet', () {
    testWidgets('displays difficulty label for easy', (tester) async {
      await tester.pumpWidget(buildOpener(
        difficulty: MonsterDifficulty.easy,
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Facile'), findsOneWidget);
    });

    testWidgets('displays difficulty label for hard', (tester) async {
      await tester.pumpWidget(buildOpener(
        difficulty: MonsterDifficulty.hard,
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Difficile'), findsOneWidget);
    });

    testWidgets('displays combat unavailable message', (tester) async {
      await tester.pumpWidget(buildOpener(
        difficulty: MonsterDifficulty.easy,
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Combat non disponible'), findsOneWidget);
    });

    testWidgets('no action button is present', (tester) async {
      await tester.pumpWidget(buildOpener(
        difficulty: MonsterDifficulty.easy,
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(FilledButton), findsNothing);
    });
  });
}
