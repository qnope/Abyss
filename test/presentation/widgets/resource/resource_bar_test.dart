import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/resource/resource_bar.dart';
import 'package:abyss/presentation/widgets/resource/resource_bar_item.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  group('ResourceBar', () {
    setUp(() => mockSvgAssets());
    tearDown(() => clearSvgMocks());

    Widget createApp({
      Map<ResourceType, int> consumption = const {},
      Map<ResourceType, int> production = const {},
    }) {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: ResourceBar(
            resources: Game.defaultResources(),
            production: production,
            consumption: consumption,
          ),
        ),
      );
    }

    testWidgets('renders all 5 resource items', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();
      expect(find.byType(ResourceBarItem), findsNWidgets(5));
    });

    testWidgets('shows resource amounts', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();
      expect(find.text('100'), findsOneWidget);
      expect(find.text('80'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('pearl is separated with a divider', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();
      final containers = tester.widgetList<Container>(
        find.byType(Container),
      );
      final divider = containers.where(
        (c) =>
            c.constraints?.maxWidth == 1 &&
            c.constraints?.maxHeight == 24,
      );
      expect(divider.isNotEmpty, isTrue);
    });

    testWidgets('default empty consumption does not break', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();
      expect(find.byType(ResourceBarItem), findsNWidgets(5));
    });

    testWidgets('passes consumption to ResourceBarItem', (tester) async {
      await tester.pumpWidget(createApp(
        production: {ResourceType.algae: 30},
        consumption: {ResourceType.algae: 10},
      ));
      await tester.pumpAndSettle();
      expect(find.text('+30/-10/t'), findsOneWidget);
    });
  });
}
