import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import '../../../helpers/test_svg_helper.dart';
import 'building_detail_sheet_harness.dart';

Map<ResourceType, Resource> _richResources() => {
      for (final t in ResourceType.values)
        t: Resource(type: t, amount: 99999),
    };

Map<BuildingType, Building> _allWithHq10() => {
      BuildingType.headquarters:
          Building(type: BuildingType.headquarters, level: 10),
      BuildingType.volcanicKernel:
          Building(type: BuildingType.volcanicKernel, level: 0),
    };

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  group('UpgradeSection kernel requirement', () {
    testWidgets('shows kernel row when missingCapturedKernel', (t) async {
      useTallSurface(t);
      await t.pumpWidget(buildSheetApp(
        building:
            Building(type: BuildingType.volcanicKernel, level: 0),
        resources: _richResources(),
        allBuildings: _allWithHq10(),
        isVolcanicKernelCaptured: false,
      ));
      await openSheet(t);
      expect(find.text('Noyau Volcanique capture requis'), findsOneWidget);
    });

    testWidgets('hides kernel row when kernel captured', (t) async {
      useTallSurface(t);
      await t.pumpWidget(buildSheetApp(
        building:
            Building(type: BuildingType.volcanicKernel, level: 0),
        resources: _richResources(),
        allBuildings: _allWithHq10(),
        isVolcanicKernelCaptured: true,
      ));
      await openSheet(t);
      expect(find.text('Noyau Volcanique capture requis'), findsNothing);
    });

    testWidgets('button disabled when kernel not captured', (t) async {
      useTallSurface(t);
      await t.pumpWidget(buildSheetApp(
        building:
            Building(type: BuildingType.volcanicKernel, level: 0),
        resources: _richResources(),
        allBuildings: _allWithHq10(),
        isVolcanicKernelCaptured: false,
      ));
      await openSheet(t);
      final btn = t.widget<ElevatedButton>(
        find.byType(ElevatedButton).last,
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('button enabled when kernel captured with resources',
        (t) async {
      useTallSurface(t);
      await t.pumpWidget(buildSheetApp(
        building:
            Building(type: BuildingType.volcanicKernel, level: 0),
        resources: _richResources(),
        allBuildings: _allWithHq10(),
        isVolcanicKernelCaptured: true,
      ));
      await openSheet(t);
      final btn = t.widget<ElevatedButton>(
        find.byType(ElevatedButton).last,
      );
      expect(btn.onPressed, isNotNull);
    });
  });
}
