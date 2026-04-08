import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/presentation/widgets/fight/monster_preview.dart';

import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Widget wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('MonsterPreview', () {
    testWidgets('renders difficulty label, level and unit count',
        (tester) async {
      const lair = MonsterLair(
        difficulty: MonsterDifficulty.medium,
        unitCount: 3,
      );
      await tester.pumpWidget(wrap(const MonsterPreview(lair: lair)));
      await tester.pumpAndSettle();

      expect(find.text('Moyen'), findsOneWidget);
      expect(find.text('Niveau 2'), findsOneWidget);
      expect(find.text('Unités: 3'), findsOneWidget);
    });

    testWidgets('renders per-level stats for medium difficulty',
        (tester) async {
      const lair = MonsterLair(
        difficulty: MonsterDifficulty.medium,
        unitCount: 2,
      );
      await tester.pumpWidget(wrap(const MonsterPreview(lair: lair)));
      await tester.pumpAndSettle();

      expect(find.text('PV: 20'), findsOneWidget);
      expect(find.text('ATK: 4'), findsOneWidget);
      expect(find.text('DEF: 2'), findsOneWidget);
    });

    testWidgets('renders per-level stats for easy difficulty',
        (tester) async {
      const lair = MonsterLair(
        difficulty: MonsterDifficulty.easy,
        unitCount: 1,
      );
      await tester.pumpWidget(wrap(const MonsterPreview(lair: lair)));
      await tester.pumpAndSettle();

      expect(find.text('Facile'), findsOneWidget);
      expect(find.text('PV: 10'), findsOneWidget);
      expect(find.text('ATK: 2'), findsOneWidget);
      expect(find.text('DEF: 1'), findsOneWidget);
    });
  });
}
