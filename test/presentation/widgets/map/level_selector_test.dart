import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/map/level_selector.dart';

void main() {
  Widget buildApp({
    int currentLevel = 1,
    Set<int> unlockedLevels = const {1},
    ValueChanged<int>? onLevelSelected,
  }) {
    return MaterialApp(
      theme: AbyssTheme.create(),
      home: Scaffold(
        body: LevelSelector(
          currentLevel: currentLevel,
          unlockedLevels: unlockedLevels,
          onLevelSelected: onLevelSelected ?? (_) {},
        ),
      ),
    );
  }

  group('LevelSelector', () {
    testWidgets('renders 3 level chips', (tester) async {
      await tester.pumpWidget(buildApp());

      expect(find.text('Niv 1: Surface'), findsOneWidget);
      expect(find.text('Niv 2: Profondeurs'), findsOneWidget);
      expect(find.text('Niv 3: Noyau'), findsOneWidget);
    });

    testWidgets('locked levels show a padlock icon', (tester) async {
      await tester.pumpWidget(
        buildApp(unlockedLevels: {1}),
      );

      // Levels 2 and 3 are locked — two padlocks expected.
      expect(find.byIcon(Icons.lock), findsNWidgets(2));
    });

    testWidgets('locked level tap does not fire callback', (tester) async {
      final taps = <int>[];

      await tester.pumpWidget(
        buildApp(
          unlockedLevels: {1},
          onLevelSelected: taps.add,
        ),
      );

      await tester.tap(find.text('Niv 2: Profondeurs'));
      await tester.pump();

      expect(taps, isEmpty);
    });

    testWidgets('unlocked level tap fires onLevelSelected', (tester) async {
      final taps = <int>[];

      await tester.pumpWidget(
        buildApp(
          currentLevel: 1,
          unlockedLevels: {1, 2},
          onLevelSelected: taps.add,
        ),
      );

      await tester.tap(find.text('Niv 2: Profondeurs'));
      await tester.pump();

      expect(taps, [2]);
    });

    testWidgets('all levels unlocked shows no padlock', (tester) async {
      await tester.pumpWidget(
        buildApp(unlockedLevels: {1, 2, 3}),
      );

      expect(find.byIcon(Icons.lock), findsNothing);
    });
  });
}
