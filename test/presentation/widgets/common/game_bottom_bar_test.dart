import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/common/game_bottom_bar.dart';

void main() {
  group('GameBottomBar', () {
    Widget createApp({
      int currentTab = 0,
      int turnNumber = 1,
      ValueChanged<int>? onTabChanged,
      VoidCallback? onNextTurn,
      VoidCallback? onSettings,
    }) {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          bottomNavigationBar: GameBottomBar(
            currentTab: currentTab,
            turnNumber: turnNumber,
            onTabChanged: onTabChanged ?? (_) {},
            onNextTurn: onNextTurn ?? () {},
            onSettings: onSettings ?? () {},
          ),
        ),
      );
    }

    testWidgets('renders 4 tabs with correct labels', (tester) async {
      await tester.pumpWidget(createApp());

      expect(find.text('Base'), findsOneWidget);
      expect(find.text('Carte'), findsOneWidget);
      expect(find.text('Tech'), findsOneWidget);
    });

    testWidgets('displays turn number text', (tester) async {
      await tester.pumpWidget(createApp(turnNumber: 3));

      expect(find.text('Tour 3'), findsOneWidget);
    });

    testWidgets('tab tap fires onTabChanged', (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(
        createApp(onTabChanged: (i) => tappedIndex = i),
      );

      await tester.tap(find.text('Carte'));
      expect(tappedIndex, 1);
    });

    testWidgets('next turn button fires onNextTurn', (tester) async {
      var called = false;
      await tester.pumpWidget(
        createApp(onNextTurn: () => called = true),
      );

      await tester.tap(find.text('Tour suivant'));
      expect(called, isTrue);
    });

    testWidgets('settings icon fires onSettings', (tester) async {
      var called = false;
      await tester.pumpWidget(
        createApp(onSettings: () => called = true),
      );

      await tester.tap(find.byIcon(Icons.settings));
      expect(called, isTrue);
    });
  });
}
