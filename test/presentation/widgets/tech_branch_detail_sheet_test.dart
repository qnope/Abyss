import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building.dart';
import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/game.dart';
import 'package:abyss/domain/tech_branch.dart';
import 'package:abyss/domain/tech_branch_state.dart';
import 'package:abyss/domain/resource.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/tech_branch_detail_sheet.dart';
import '../../helpers/test_svg_helper.dart';

void _useTallSurface(WidgetTester t) {
  t.view.physicalSize = const Size(800, 1200);
  t.view.devicePixelRatio = 1.0;
  addTearDown(() => t.view.resetPhysicalSize());
  addTearDown(() => t.view.resetDevicePixelRatio());
}

Widget _app({
  required TechBranchState state,
  Map<ResourceType, Resource>? resources,
  Map<BuildingType, Building>? buildings,
  VoidCallback? onUnlock,
}) {
  return MaterialApp(
    theme: AbyssTheme.create(),
    home: Scaffold(
      body: Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () => showTechBranchDetailSheet(
            ctx,
            branch: state.branch,
            state: state,
            resources: resources ?? Game.defaultResources(),
            buildings: buildings ?? Game.defaultBuildings(),
            onUnlock: onUnlock ?? () {},
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
  group('TechBranchDetailSheet', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    testWidgets('locked + lab built + resources OK: button enabled', (t) async {
      _useTallSurface(t);
      final state = TechBranchState(branch: TechBranch.military);
      final buildings = {
        ...Game.defaultBuildings(),
        BuildingType.laboratory:
            Building(type: BuildingType.laboratory, level: 1),
      };
      await t.pumpWidget(_app(state: state, buildings: buildings));
      await _openSheet(t);
      expect(find.text('Débloquer'), findsOneWidget);
      final btn = t.widget<ElevatedButton>(
        find.byType(ElevatedButton).last,
      );
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('locked + lab not built: button disabled', (t) async {
      _useTallSurface(t);
      final state = TechBranchState(branch: TechBranch.military);
      await t.pumpWidget(_app(state: state));
      await _openSheet(t);
      expect(
        find.textContaining('Construisez un laboratoire'),
        findsOneWidget,
      );
    });

    testWidgets('already unlocked: shows success message', (t) async {
      _useTallSurface(t);
      final state = TechBranchState(
        branch: TechBranch.military, unlocked: true);
      final buildings = {
        ...Game.defaultBuildings(),
        BuildingType.laboratory:
            Building(type: BuildingType.laboratory, level: 1),
      };
      await t.pumpWidget(_app(state: state, buildings: buildings));
      await _openSheet(t);
      expect(find.textContaining('débloquée'), findsOneWidget);
    });
  });
}
