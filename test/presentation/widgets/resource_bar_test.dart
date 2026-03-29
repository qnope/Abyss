import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/resource_bar.dart';
import 'package:abyss/presentation/widgets/resource_bar_item.dart';
import '../../helpers/test_svg_helper.dart';

void main() {
  group('ResourceBar', () {
    setUp(() => mockSvgAssets());
    tearDown(() => clearSvgMocks());

    Widget createApp() {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: ResourceBar(resources: Game.defaultResources()),
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

      expect(find.text('100'), findsOneWidget); // algae
      expect(find.text('80'), findsOneWidget);  // coral
      expect(find.text('50'), findsOneWidget);  // ore
      expect(find.text('60'), findsOneWidget);  // energy
      expect(find.text('5'), findsOneWidget);   // pearl
    });

    testWidgets('pearl is separated with a divider', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // The ResourceBar has a Container used as a visual divider
      // (width=1, height=24) between production resources and pearl.
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
  });
}
