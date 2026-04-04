import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building.dart';
import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/game.dart';
import 'package:abyss/domain/resource.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/domain/tech_branch.dart';
import 'package:abyss/domain/tech_branch_state.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/tech_node_detail_sheet.dart';
import '../../helpers/test_svg_helper.dart';

void _useTallSurface(WidgetTester t) {
  t.view.physicalSize = const Size(800, 1200);
  t.view.devicePixelRatio = 1.0;
  addTearDown(() => t.view.resetPhysicalSize());
  addTearDown(() => t.view.resetDevicePixelRatio());
}

Widget _app({
  required TechBranch branch,
  required int level,
  required TechBranchState state,
  Map<ResourceType, Resource>? resources,
  Map<BuildingType, Building>? buildings,
  VoidCallback? onResearch,
}) {
  return MaterialApp(
    theme: AbyssTheme.create(),
    home: Scaffold(
      body: Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () => showTechNodeDetailSheet(
            ctx,
            branch: branch,
            level: level,
            state: state,
            resources: resources ?? Game.defaultResources(),
            buildings: buildings ?? Game.defaultBuildings(),
            onResearch: onResearch ?? () {},
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

void main() {
  group('TechNodeDetailSheet', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    testWidgets('next node + resources OK + lab OK: button enabled',
        (t) async {
      _useTallSurface(t);
      final state = TechBranchState(
        branch: TechBranch.military, unlocked: true, researchLevel: 0);
      final resources = {
        for (final r in ResourceType.values)
          r: Resource(type: r, amount: 500, maxStorage: 5000),
      };
      final buildings = {
        ...Game.defaultBuildings(),
        BuildingType.laboratory:
            Building(type: BuildingType.laboratory, level: 1),
      };
      await t.pumpWidget(_app(
        branch: TechBranch.military, level: 1, state: state,
        resources: resources, buildings: buildings,
      ));
      await _openSheet(t);
      expect(find.text('Rechercher'), findsOneWidget);
      final btn = t.widget<ElevatedButton>(
        find.byType(ElevatedButton).last,
      );
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('already researched: shows completed message', (t) async {
      _useTallSurface(t);
      final state = TechBranchState(
        branch: TechBranch.military, unlocked: true, researchLevel: 2);
      await t.pumpWidget(
        _app(branch: TechBranch.military, level: 1, state: state));
      await _openSheet(t);
      expect(find.textContaining('complétée'), findsOneWidget);
    });

    testWidgets('future node: shows prerequisite message', (t) async {
      _useTallSurface(t);
      final state = TechBranchState(
        branch: TechBranch.military, unlocked: true, researchLevel: 0);
      await t.pumpWidget(
        _app(branch: TechBranch.military, level: 3, state: state));
      await _openSheet(t);
      expect(find.textContaining('niveau 2'), findsOneWidget);
    });

    testWidgets('level 3 military shows correct bonus text', (t) async {
      _useTallSurface(t);
      final state = TechBranchState(
        branch: TechBranch.military, unlocked: true, researchLevel: 2);
      await t.pumpWidget(
        _app(branch: TechBranch.military, level: 3, state: state));
      await _openSheet(t);
      expect(
        find.textContaining('+60% attaque et défense'),
        findsOneWidget,
      );
    });
  });
}
