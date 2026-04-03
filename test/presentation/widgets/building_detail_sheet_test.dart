import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building.dart';
import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/game.dart';
import 'package:abyss/domain/resource.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/building_detail_sheet.dart';
import '../../helpers/test_svg_helper.dart';

Widget _app({
  required Building building,
  Map<ResourceType, Resource>? resources,
  Map<BuildingType, Building>? allBuildings,
  VoidCallback? onUpgrade,
}) {
  return MaterialApp(
    theme: AbyssTheme.create(),
    home: Scaffold(
      body: Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () => showBuildingDetailSheet(
            ctx,
            building: building,
            resources: resources ?? Game.defaultResources(),
            allBuildings: allBuildings ?? {building.type: building},
            onUpgrade: onUpgrade ?? () {},
          ),
          child: const Text('Open'),
        ),
      ),
    ),
  );
}

Future<void> _openSheet(WidgetTester t) async {
  await t.tap(find.text('Open'));
  await t.pumpAndSettle();
}

void _useTallSurface(WidgetTester t) {
  t.view.physicalSize = const Size(800, 1200);
  t.view.devicePixelRatio = 1.0;
  addTearDown(() => t.view.resetPhysicalSize());
  addTearDown(() => t.view.resetDevicePixelRatio());
}

Building _hq([int level = 0]) =>
    Building(type: BuildingType.headquarters, level: level);

void main() {
  group('BuildingDetailSheet', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    testWidgets('shows building name and level', (t) async {
      _useTallSurface(t);
      await t.pumpWidget(_app(building: _hq(2)));
      await _openSheet(t);
      expect(find.text('Quartier Général'), findsOneWidget);
      expect(find.text('Niveau 2'), findsOneWidget);
    });

    testWidgets('shows building description', (t) async {
      _useTallSurface(t);
      await t.pumpWidget(_app(building: _hq(1)));
      await _openSheet(t);
      expect(find.textContaining('Centre de commandement'), findsOneWidget);
    });

    testWidgets('shows upgrade costs with amounts', (t) async {
      _useTallSurface(t);
      await t.pumpWidget(_app(building: _hq()));
      await _openSheet(t);
      expect(find.text('80/30'), findsOneWidget);
      expect(find.text('50/20'), findsOneWidget);
    });

    testWidgets('upgrade button enabled with sufficient resources',
        (t) async {
      _useTallSurface(t);
      await t.pumpWidget(_app(building: _hq()));
      await _openSheet(t);
      final btn = t.widget<ElevatedButton>(
        find.byType(ElevatedButton).last,
      );
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('upgrade button disabled with insufficient resources',
        (t) async {
      _useTallSurface(t);
      final poor = {
        for (final type in ResourceType.values)
          type: Resource(type: type, amount: 1),
      };
      await t.pumpWidget(_app(building: _hq(), resources: poor));
      await _openSheet(t);
      final btn = t.widget<ElevatedButton>(
        find.byType(ElevatedButton).last,
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('shows max level message at level 10', (t) async {
      _useTallSurface(t);
      await t.pumpWidget(_app(building: _hq(10)));
      await _openSheet(t);
      expect(find.text('Niveau maximum atteint'), findsOneWidget);
    });

    testWidgets('shows Construire button when level 0', (t) async {
      _useTallSurface(t);
      await t.pumpWidget(_app(building: _hq()));
      await _openSheet(t);
      expect(find.text('Construire'), findsOneWidget);
    });

    testWidgets('shows Améliorer button when level > 0', (t) async {
      _useTallSurface(t);
      await t.pumpWidget(_app(building: _hq(1)));
      await _openSheet(t);
      expect(find.text('Améliorer'), findsOneWidget);
    });

    testWidgets('shows costs for algaeFarm level 0->1', (t) async {
      _useTallSurface(t);
      final farm = Building(type: BuildingType.algaeFarm, level: 0);
      await t.pumpWidget(_app(
        building: farm,
        allBuildings: {farm.type: farm, BuildingType.headquarters: _hq(1)},
      ));
      await _openSheet(t);
      expect(find.text('80/20'), findsOneWidget);
    });

    testWidgets('shows HQ prerequisite for algaeFarm when HQ not built',
        (t) async {
      _useTallSurface(t);
      final farm = Building(type: BuildingType.algaeFarm, level: 0);
      await t.pumpWidget(_app(
        building: farm,
        allBuildings: {farm.type: farm, BuildingType.headquarters: _hq()},
      ));
      await _openSheet(t);
      expect(find.text('Quartier Général'), findsOneWidget);
      expect(find.text('Niv. 1'), findsOneWidget);
    });

    testWidgets('upgrade button disabled when HQ prerequisite not met',
        (t) async {
      _useTallSurface(t);
      final farm = Building(type: BuildingType.algaeFarm, level: 0);
      await t.pumpWidget(_app(
        building: farm,
        allBuildings: {farm.type: farm, BuildingType.headquarters: _hq()},
      ));
      await _openSheet(t);
      final btn = t.widget<ElevatedButton>(
        find.byType(ElevatedButton).last,
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('shows max level message for algaeFarm at level 5',
        (t) async {
      _useTallSurface(t);
      final farm = Building(type: BuildingType.algaeFarm, level: 5);
      await t.pumpWidget(_app(building: farm));
      await _openSheet(t);
      expect(find.text('Niveau maximum atteint'), findsOneWidget);
    });
  });
}
