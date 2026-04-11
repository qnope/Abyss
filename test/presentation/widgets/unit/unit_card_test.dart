import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/unit/unit_card.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  group('UnitCard', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    Widget createApp({
      UnitType type = UnitType.scout,
      Map<int, int> countsPerLevel = const {1: 0},
      bool isUnlocked = true,
      VoidCallback? onTap,
    }) {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: UnitCard(
            unitType: type,
            countsPerLevel: countsPerLevel,
            isUnlocked: isUnlocked,
            onTap: onTap ?? () {},
          ),
        ),
      );
    }

    testWidgets('unlocked card displays unit name', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();
      expect(find.text('Eclaireur'), findsOneWidget);
    });

    testWidgets('unlocked card shows count', (tester) async {
      await tester.pumpWidget(createApp(countsPerLevel: {1: 5}));
      await tester.pumpAndSettle();
      expect(find.text('5 unites'), findsOneWidget);
    });

    testWidgets('locked card shows Verrouille', (tester) async {
      await tester.pumpWidget(createApp(isUnlocked: false));
      await tester.pumpAndSettle();
      expect(find.text('Verrouille'), findsOneWidget);
    });

    testWidgets('locked card shows lock icon', (tester) async {
      await tester.pumpWidget(createApp(isUnlocked: false));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('calls onTap callback when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(createApp(onTap: () => tapped = true));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(UnitCard));
      expect(tapped, isTrue);
    });

    testWidgets('locked card has reduced opacity', (tester) async {
      await tester.pumpWidget(createApp(isUnlocked: false));
      await tester.pumpAndSettle();
      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 0.5);
    });

    testWidgets('shows per-level breakdown when multiple levels',
        (tester) async {
      await tester.pumpWidget(
        createApp(countsPerLevel: {1: 5, 2: 3}),
      );
      await tester.pumpAndSettle();
      expect(find.text('Niv 1: 5 · Niv 2: 3'), findsOneWidget);
    });

    testWidgets('shows simple count when only one level has units',
        (tester) async {
      await tester.pumpWidget(
        createApp(countsPerLevel: {1: 7}),
      );
      await tester.pumpAndSettle();
      expect(find.text('7 unites'), findsOneWidget);
    });

    testWidgets('ignores levels with zero count', (tester) async {
      await tester.pumpWidget(
        createApp(countsPerLevel: {1: 4, 2: 0}),
      );
      await tester.pumpAndSettle();
      expect(find.text('4 unites'), findsOneWidget);
    });
  });
}
