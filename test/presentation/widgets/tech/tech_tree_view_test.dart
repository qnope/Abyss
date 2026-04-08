import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_branch_state.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/tech/tech_tree_view.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  group('TechTreeView', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    TechBranch? tappedBranch;
    TechBranch? tappedNodeBranch;
    int? tappedNodeLevel;

    Widget build({
      Map<TechBranch, TechBranchState>? branches,
      Map<BuildingType, Building>? buildings,
    }) {
      tappedBranch = null;
      tappedNodeBranch = null;
      tappedNodeLevel = null;
      final player = Player(name: 'Tester');
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: TechTreeView(
            techBranches: branches ?? player.techBranches,
            buildings: buildings ?? player.buildings,
            resources: player.resources,
            onBranchTap: (b) => tappedBranch = b,
            onNodeTap: (b, l) {
              tappedNodeBranch = b;
              tappedNodeLevel = l;
            },
          ),
        ),
      );
    }

    testWidgets('lab level 0: all branch headers locked (opacity 0.3)',
        (t) async {
      await t.pumpWidget(build());
      await t.pumpAndSettle();
      // All branches locked means all Opacity widgets use 0.3
      final opacities = t.widgetList<Opacity>(find.byType(Opacity));
      expect(opacities.every((o) => o.opacity == 0.3), isTrue);
    });

    testWidgets('military unlocked level 2: nodes 1-2 researched', (t) async {
      final branches = {
        TechBranch.military: TechBranchState(
          branch: TechBranch.military, unlocked: true, researchLevel: 2),
        TechBranch.resources: TechBranchState(branch: TechBranch.resources),
        TechBranch.explorer: TechBranchState(branch: TechBranch.explorer),
      };
      final buildings = {
        ...Player(name: 'Tester').buildings,
        BuildingType.laboratory:
            Building(type: BuildingType.laboratory, level: 3),
      };
      await t.pumpWidget(build(branches: branches, buildings: buildings));
      await t.pumpAndSettle();
      // Researched nodes show 'Niv. 1' and 'Niv. 2'
      expect(find.text('Niv. 1'), findsWidgets);
      expect(find.text('Niv. 2'), findsWidgets);
    });

    testWidgets('onBranchTap fires with correct branch', (t) async {
      final branches = {
        TechBranch.military: TechBranchState(
          branch: TechBranch.military, unlocked: true),
        TechBranch.resources: TechBranchState(branch: TechBranch.resources),
        TechBranch.explorer: TechBranchState(branch: TechBranch.explorer),
      };
      await t.pumpWidget(build(branches: branches));
      await t.pumpAndSettle();
      // The first TechNodeWidget with full opacity is military header
      final opacityWidgets = find.byType(Opacity);
      // Tap the first branch header (military)
      await t.tap(opacityWidgets.first);
      expect(tappedBranch, TechBranch.military);
    });

    testWidgets('onNodeTap fires with correct branch and level', (t) async {
      final branches = {
        TechBranch.military: TechBranchState(
          branch: TechBranch.military, unlocked: true, researchLevel: 1),
        TechBranch.resources: TechBranchState(branch: TechBranch.resources),
        TechBranch.explorer: TechBranchState(branch: TechBranch.explorer),
      };
      await t.pumpWidget(build(branches: branches));
      await t.pumpAndSettle();
      // Tap 'Niv. 1' text which is inside a node
      await t.tap(find.text('Niv. 1').first);
      expect(tappedNodeBranch, TechBranch.military);
      expect(tappedNodeLevel, 1);
    });
  });
}
