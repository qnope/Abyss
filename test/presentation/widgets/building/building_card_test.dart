import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/building/building_card.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  group('BuildingCard', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    Widget createApp({required Building building, VoidCallback? onTap}) {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: BuildingCard(
            building: building,
            onTap: onTap ?? () {},
          ),
        ),
      );
    }

    testWidgets('displays building name', (tester) async {
      final building = Building(type: BuildingType.headquarters, level: 1);
      await tester.pumpWidget(createApp(building: building));
      await tester.pumpAndSettle();

      expect(find.text('Quartier Général'), findsOneWidget);
    });

    testWidgets('displays level for a built building', (tester) async {
      final building = Building(type: BuildingType.headquarters, level: 3);
      await tester.pumpWidget(createApp(building: building));
      await tester.pumpAndSettle();

      expect(find.text('Niveau 3'), findsOneWidget);
    });

    testWidgets('displays Non construit for level 0', (tester) async {
      final building = Building(type: BuildingType.headquarters, level: 0);
      await tester.pumpWidget(createApp(building: building));
      await tester.pumpAndSettle();

      expect(find.text('Non construit'), findsOneWidget);
    });

    testWidgets('card is dimmed when level 0', (tester) async {
      final building = Building(type: BuildingType.headquarters, level: 0);
      await tester.pumpWidget(createApp(building: building));
      await tester.pumpAndSettle();

      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 0.5);
    });

    testWidgets('calls onTap callback when tapped', (tester) async {
      var tapped = false;
      final building = Building(type: BuildingType.headquarters, level: 1);
      await tester.pumpWidget(
        createApp(building: building, onTap: () => tapped = true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(BuildingCard));
      expect(tapped, isTrue);
    });
  });
}
