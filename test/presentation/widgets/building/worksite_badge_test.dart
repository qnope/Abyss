import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/worksite/worksite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../helpers/test_svg_helper.dart';
import 'building_detail_sheet_harness.dart';

Map<ResourceType, Resource> _rich() => {
  for (final t in ResourceType.values) t: Resource(type: t, amount: 99999),
};

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  final farm = Building(type: BuildingType.algaeFarm, level: 0);
  final hq = Building(type: BuildingType.headquarters, level: 1);

  testWidgets('a used site greys out the upgrade button', (t) async {
    useTallSurface(t);
    await t.pumpWidget(
      buildSheetApp(
        building: farm,
        resources: _rich(),
        allBuildings: {BuildingType.headquarters: hq, farm.type: farm},
        worksite: Worksite(upgrades: 1),
      ),
    );
    await openSheet(t);
    expect(find.text('Chantiers occupés ce tour'), findsOneWidget);
    final button = t.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Construire'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('a free site keeps the upgrade button active', (t) async {
    useTallSurface(t);
    await t.pumpWidget(
      buildSheetApp(
        building: farm,
        resources: _rich(),
        allBuildings: {BuildingType.headquarters: hq, farm.type: farm},
      ),
    );
    await openSheet(t);
    expect(find.text('Chantiers occupés ce tour'), findsNothing);
    final button = t.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Construire'),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('the HQ sheet tells which level opens the next site', (t) async {
    useTallSurface(t);
    await t.pumpWidget(
      buildSheetApp(
        building: hq,
        resources: _rich(),
        allBuildings: {BuildingType.headquarters: hq},
      ),
    );
    await openSheet(t);
    expect(
      find.text('Chantiers libres ce tour : 1/1 · +1 au QG 5'),
      findsOneWidget,
    );
  });
}
