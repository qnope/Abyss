import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/presentation/extensions/resource_type_extensions.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/resource/resource_bar.dart';
import 'package:abyss/presentation/widgets/resource/resource_bar_item.dart';
import '../../../helpers/l10n_fixtures.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  group('ResourceBar', () {
    setUp(() => mockSvgAssets());
    tearDown(() => clearSvgMocks());

    Widget createApp({
      Map<ResourceType, int> consumption = const {},
      Map<ResourceType, int> production = const {},
    }) {
      final player = Player(name: 'Nemo');
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: ResourceBar(
            resources: player.resources,
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
      expect(find.text('100'), findsNWidgets(2));
      expect(find.text('300'), findsOneWidget);
      expect(find.text('150'), findsOneWidget);
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
            c.constraints?.maxHeight == 36,
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
    /// Taps the [type] item of the bar, on a phone-sized screen.
    Future<void> tapItem(WidgetTester tester, ResourceType type) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pump();
      await tester.tap(find.byWidgetPredicate(
        (w) => w is ResourceBarItem && w.resource.type == type,
      ));
      await tester.pumpAndSettle();
    }

    Finder inSheet(String text) => find.descendant(
        of: find.byType(BottomSheet), matching: find.text(text));

    testWidgets('tapping a resource opens its detail with its production', (
      tester,
    ) async {
      await tester.pumpWidget(createApp(production: {ResourceType.algae: 30}));
      await tapItem(tester, ResourceType.algae);
      expect(inSheet(ResourceType.algae.flavorText(fr)), findsOneWidget);
      expect(inSheet(fr.resourceProduction), findsOneWidget);
      expect(inSheet('+30/t'), findsOneWidget);
    });

    testWidgets('tapping the pearls opens the pearl detail', (tester) async {
      await tester.pumpWidget(createApp(production: {ResourceType.pearl: 2}));
      await tapItem(tester, ResourceType.pearl);
      expect(inSheet(ResourceType.pearl.flavorText(fr)), findsOneWidget);
      expect(inSheet('+2/t'), findsOneWidget);
    });
  });
}
