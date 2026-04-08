import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import '../../../helpers/test_svg_helper.dart';
import 'building_detail_sheet_harness.dart';

void main() {
  group('BuildingDetailSheet algaeFarm', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    testWidgets('shows costs for algaeFarm level 0->1', (t) async {
      useTallSurface(t);
      final farm = Building(type: BuildingType.algaeFarm, level: 0);
      await t.pumpWidget(buildSheetApp(
        building: farm,
        allBuildings: {farm.type: farm, BuildingType.headquarters: hq(1)},
      ));
      await openSheet(t);
      expect(find.text('80/20'), findsOneWidget);
    });

    testWidgets('shows HQ prerequisite for algaeFarm when HQ not built',
        (t) async {
      useTallSurface(t);
      final farm = Building(type: BuildingType.algaeFarm, level: 0);
      await t.pumpWidget(buildSheetApp(
        building: farm,
        allBuildings: {farm.type: farm, BuildingType.headquarters: hq()},
      ));
      await openSheet(t);
      expect(find.text('Quartier Général'), findsOneWidget);
      expect(find.text('Niv. 1'), findsOneWidget);
    });

    testWidgets('upgrade button disabled when HQ prerequisite not met',
        (t) async {
      useTallSurface(t);
      final farm = Building(type: BuildingType.algaeFarm, level: 0);
      await t.pumpWidget(buildSheetApp(
        building: farm,
        allBuildings: {farm.type: farm, BuildingType.headquarters: hq()},
      ));
      await openSheet(t);
      final btn = t.widget<ElevatedButton>(
        find.byType(ElevatedButton).last,
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('shows max level message for algaeFarm at level 5',
        (t) async {
      useTallSurface(t);
      final farm = Building(type: BuildingType.algaeFarm, level: 5);
      await t.pumpWidget(buildSheetApp(building: farm));
      await openSheet(t);
      expect(find.text('Niveau maximum atteint'), findsOneWidget);
    });
  });
}
