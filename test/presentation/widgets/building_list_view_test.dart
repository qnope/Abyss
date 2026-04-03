import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building.dart';
import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/game.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/building_list_view.dart';
import '../../helpers/test_svg_helper.dart';

void main() {
  group('BuildingListView', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    Widget createApp({
      required Map<BuildingType, Building> buildings,
      void Function(Building)? onBuildingTap,
    }) {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: BuildingListView(
            buildings: buildings,
            resources: Game.defaultResources(),
            onBuildingTap: onBuildingTap ?? (_) {},
          ),
        ),
      );
    }

    testWidgets('displays one BuildingCard per building', (tester) async {
      final buildings = {
        BuildingType.headquarters:
            Building(type: BuildingType.headquarters, level: 1),
      };
      await tester.pumpWidget(createApp(buildings: buildings));
      await tester.pumpAndSettle();

      expect(find.text('Quartier Général'), findsOneWidget);
    });

    testWidgets('displays all 5 buildings including production buildings',
        (tester) async {
      final buildings = Game.defaultBuildings();
      await tester.pumpWidget(createApp(buildings: buildings));
      await tester.pumpAndSettle();

      expect(find.text('Quartier Général'), findsOneWidget);
      expect(find.text('Ferme d\'algues'), findsOneWidget);
      expect(find.text('Mine de corail'), findsOneWidget);
      expect(find.text('Extracteur de minerai'), findsOneWidget);
      expect(find.text('Panneau solaire'), findsOneWidget);
    });

    testWidgets('calls onBuildingTap with correct building', (tester) async {
      Building? tappedBuilding;
      final buildings = {
        BuildingType.headquarters:
            Building(type: BuildingType.headquarters, level: 1),
      };
      await tester.pumpWidget(
        createApp(
          buildings: buildings,
          onBuildingTap: (b) => tappedBuilding = b,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Quartier Général'));
      expect(tappedBuilding, buildings[BuildingType.headquarters]);
    });
  });
}
