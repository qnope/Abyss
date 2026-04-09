import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/presentation/widgets/building/base_shield_badge.dart';
import 'package:abyss/presentation/widgets/building/coral_citadel_info_section.dart';
import '../../../helpers/test_svg_helper.dart';
import 'building_detail_sheet_harness.dart';

void main() {
  group('BuildingDetailSheet headquarters', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    testWidgets('shows building name and level', (t) async {
      useTallSurface(t);
      await t.pumpWidget(buildSheetApp(building: hq(2)));
      await openSheet(t);
      expect(find.text('Quartier Général'), findsOneWidget);
      expect(find.text('Niveau 2'), findsOneWidget);
    });

    testWidgets('shows building description', (t) async {
      useTallSurface(t);
      await t.pumpWidget(buildSheetApp(building: hq(1)));
      await openSheet(t);
      expect(find.textContaining('Centre de commandement'), findsOneWidget);
    });

    testWidgets('shows upgrade costs with amounts', (t) async {
      useTallSurface(t);
      await t.pumpWidget(buildSheetApp(building: hq()));
      await openSheet(t);
      expect(find.text('80/30'), findsOneWidget);
      expect(find.text('50/20'), findsOneWidget);
    });

    testWidgets('upgrade button enabled with sufficient resources',
        (t) async {
      useTallSurface(t);
      await t.pumpWidget(buildSheetApp(building: hq()));
      await openSheet(t);
      final btn = t.widget<ElevatedButton>(
        find.byType(ElevatedButton).last,
      );
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('upgrade button disabled with insufficient resources',
        (t) async {
      useTallSurface(t);
      final poor = {
        for (final type in ResourceType.values)
          type: Resource(type: type, amount: 1),
      };
      await t.pumpWidget(buildSheetApp(building: hq(), resources: poor));
      await openSheet(t);
      final btn = t.widget<ElevatedButton>(
        find.byType(ElevatedButton).last,
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('shows max level message at level 10', (t) async {
      useTallSurface(t);
      await t.pumpWidget(buildSheetApp(building: hq(10)));
      await openSheet(t);
      expect(find.text('Niveau maximum atteint'), findsOneWidget);
    });

    testWidgets('shows Construire button when level 0', (t) async {
      useTallSurface(t);
      await t.pumpWidget(buildSheetApp(building: hq()));
      await openSheet(t);
      expect(find.text('Construire'), findsOneWidget);
    });

    testWidgets('shows Améliorer button when level > 0', (t) async {
      useTallSurface(t);
      await t.pumpWidget(buildSheetApp(building: hq(1)));
      await openSheet(t);
      expect(find.text('Améliorer'), findsOneWidget);
    });

    testWidgets('does NOT show CoralCitadelInfoSection for non-citadel',
        (t) async {
      useTallSurface(t);
      await t.pumpWidget(buildSheetApp(building: hq(1)));
      await openSheet(t);
      expect(find.byType(CoralCitadelInfoSection), findsNothing);
      expect(find.textContaining('Bonus DEF actuel'), findsNothing);
    });

    testWidgets('HQ sheet with citadel level 4 shows +80% badge', (t) async {
      useTallSurface(t);
      await t.pumpWidget(buildSheetApp(
        building: hq(3),
        allBuildings: {
          BuildingType.headquarters: hq(3),
          BuildingType.coralCitadel:
              Building(type: BuildingType.coralCitadel, level: 4),
        },
      ));
      await openSheet(t);
      expect(find.byType(BaseShieldBadge), findsOneWidget);
      expect(find.text('Bouclier de la base : +80%'), findsOneWidget);
    });

    testWidgets('HQ sheet with citadel level 0 shows no badge', (t) async {
      useTallSurface(t);
      await t.pumpWidget(buildSheetApp(
        building: hq(3),
        allBuildings: {
          BuildingType.headquarters: hq(3),
          BuildingType.coralCitadel:
              Building(type: BuildingType.coralCitadel, level: 0),
        },
      ));
      await openSheet(t);
      // BaseShieldBadge is in tree but renders SizedBox.shrink (no label).
      expect(find.textContaining('Bouclier de la base'), findsNothing);
    });
  });

  group('BuildingDetailSheet coralCitadel', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    testWidgets('shows CoralCitadelInfoSection with bonus rows', (t) async {
      useTallSurface(t);
      final citadel = Building(type: BuildingType.coralCitadel, level: 2);
      await t.pumpWidget(buildSheetApp(
        building: citadel,
        allBuildings: {
          citadel.type: citadel,
          BuildingType.headquarters: hq(10),
        },
      ));
      await openSheet(t);
      expect(find.byType(CoralCitadelInfoSection), findsOneWidget);
      expect(find.text('Bonus DEF actuel : +40%'), findsOneWidget);
      expect(find.text('Prochain niveau : +60%'), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
      // Upgrade button still rendered alongside the info section.
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('shows apogee message at max level', (t) async {
      useTallSurface(t);
      final citadel = Building(type: BuildingType.coralCitadel, level: 5);
      await t.pumpWidget(buildSheetApp(
        building: citadel,
        allBuildings: {
          citadel.type: citadel,
          BuildingType.headquarters: hq(10),
        },
      ));
      await openSheet(t);
      expect(find.byType(CoralCitadelInfoSection), findsOneWidget);
      expect(find.text('Bonus DEF actuel : +100%'), findsOneWidget);
      expect(find.text('Bouclier à son apogée'), findsOneWidget);
    });
  });
}
