import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/domain/tech/tech_branch_state.dart';
import 'package:abyss/presentation/widgets/tech/tech_tree_view.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  group('TechTreeView', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    TechBranch? tappedBranch;
    TechBranch? tappedNodeBranch;
    int? tappedNodeLevel;

    Map<TechBranch, TechBranchState> militaryAt(int level) => {
      TechBranch.military: TechBranchState(
        branch: TechBranch.military, unlocked: true, researchLevel: level),
      TechBranch.resources: TechBranchState(branch: TechBranch.resources),
      TechBranch.explorer: TechBranchState(branch: TechBranch.explorer),
    };

    Map<BuildingType, Building> labAt(int level) => {
      ...Player(name: 'Tester').buildings,
      BuildingType.laboratory:
          Building(type: BuildingType.laboratory, level: level),
    };

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

    testWidgets('lab level 0: header says lab is not built', (t) async {
      await t.pumpWidget(build());
      await t.pumpAndSettle();
      expect(find.text('Laboratoire non construit'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsNWidgets(3));
    });

    testWidgets('shows bonus of every node in every branch', (t) async {
      await t.pumpWidget(build());
      await t.pumpAndSettle();
      expect(find.text('+20%'), findsNWidgets(3));
      expect(find.text('+100%'), findsNWidgets(3));
    });

    testWidgets('header sums up researched bonus', (t) async {
      await t.pumpWidget(
        build(branches: militaryAt(2), buildings: labAt(3)));
      await t.pumpAndSettle();
      expect(find.text('Laboratoire · Niv. 3'), findsOneWidget);
      // One in the header chip, one on the level 2 node.
      expect(find.text('+40%'), findsNWidgets(4));
    });

    testWidgets('nodes above lab level show lab requirement', (t) async {
      await t.pumpWidget(
        build(branches: militaryAt(2), buildings: labAt(3)));
      await t.pumpAndSettle();
      expect(find.text('Labo 4'), findsNWidgets(3));
      expect(find.text('Labo 5'), findsNWidgets(3));
    });

    testWidgets('onBranchTap fires with correct branch', (t) async {
      await t.pumpWidget(build(branches: militaryAt(0)));
      await t.pumpAndSettle();
      await t.tap(find.text('Explorateur'));
      expect(tappedBranch, TechBranch.explorer);
    });

    testWidgets('onNodeTap fires with correct branch and level', (t) async {
      await t.pumpWidget(
        build(branches: militaryAt(1), buildings: labAt(3)));
      await t.pumpAndSettle();
      await t.tap(find.text('+60%').first);
      expect(tappedNodeBranch, TechBranch.military);
      expect(tappedNodeLevel, 3);
    });
  });
}
