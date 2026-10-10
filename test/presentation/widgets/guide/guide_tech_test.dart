import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/objective/guide/guide_target.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/presentation/extensions/tech_branch_extensions.dart';
import 'package:abyss/presentation/extensions/tech_node_extensions.dart';
import 'package:abyss/presentation/widgets/tech/tech_branch_medallion.dart';
import 'package:abyss/presentation/widgets/tech/tech_node_widget.dart';
import 'package:abyss/presentation/widgets/tech/tech_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';
import 'guide_widget_helpers.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Future<void> pumpReef(WidgetTester tester, GuideTarget target) async {
    tester.view.physicalSize = const Size(390, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final player = Player(name: 'Nemo');
    player.techBranches[TechBranch.explorer]!.unlocked = true;
    await tester.pumpWidget(
      guidedApp(
        TechTreeView(
          techBranches: player.techBranches,
          buildings: {
            ...player.buildings,
            BuildingType.laboratory: Building(
              type: BuildingType.laboratory,
              level: 1,
            ),
          },
          resources: player.resources,
          onUnlock: (_) {},
          onResearch: (_, _) {},
        ),
        target,
      ),
    );
    await tester.pump();
  }

  Finder medallion(TechBranch branch) => find.byWidgetPredicate(
    (widget) =>
        widget is TechBranchMedallion && widget.label == branch.displayName,
  );

  Finder firstNode(TechBranch branch) => find.byWidgetPredicate(
    (widget) =>
        widget is TechNodeWidget && widget.iconPath == branch.nodeIconPath(1),
  );

  testWidgets('the halo surrounds the medallions of the branches to unlock', (
    tester,
  ) async {
    await pumpReef(tester, GuideTarget.unlock(TechBranch.values.toSet()));

    expect(activeHalos, findsNWidgets(3));
    for (final branch in TechBranch.values) {
      expect(
        find.descendant(of: medallion(branch), matching: activeHalos),
        findsOneWidget,
      );
    }
  });

  testWidgets('the halo surrounds the first node of the branch unlocked', (
    tester,
  ) async {
    await pumpReef(tester, const GuideTarget.research({TechBranch.explorer}));

    expect(activeHalos, findsOneWidget);
    expect(haloAround(firstNode(TechBranch.explorer)), findsOneWidget);
  });
}
