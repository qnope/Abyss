import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_branch_state.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/tech/tech_tree_view.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  group('TechTreeView', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    TechBranch? unlocked;
    TechBranch? researched;

    Map<TechBranch, TechBranchState> militaryAt(int? level) => {
      TechBranch.military: TechBranchState(branch: TechBranch.military,
        unlocked: level != null, researchLevel: level ?? 0),
      TechBranch.resources: TechBranchState(branch: TechBranch.resources),
      TechBranch.explorer: TechBranchState(branch: TechBranch.explorer),
    };

    Widget build(Map<TechBranch, TechBranchState> branches, int lab) {
      unlocked = null;
      researched = null;
      final player = Player(name: 'Tester');
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: TechTreeView(
            techBranches: branches,
            buildings: {
              ...player.buildings,
              BuildingType.laboratory:
                  Building(type: BuildingType.laboratory, level: lab),
            },
            resources: {
              for (final t in ResourceType.values)
                t: Resource(type: t, amount: 450),
            },
            onUnlock: (b) => unlocked = b,
            onResearch: (b) => researched = b,
          ),
        ),
      );
    }

    Future<void> pump(WidgetTester t, Widget w) async {
      t.view.physicalSize = const Size(390, 760);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(w);
      await t.pumpAndSettle();
    }

    testWidgets('no popup until something is tapped', (t) async {
      await pump(t, build(militaryAt(2), 3));
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('lab not built: unlocking is blocked', (t) async {
      await pump(t, build(militaryAt(null), 0));
      await t.tap(find.textContaining('Militaire'));
      await t.pumpAndSettle();
      expect(find.text('Laboratoire niveau 1 requis'), findsOneWidget);
      final button = t.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('tapping a node opens a popup to research it', (t) async {
      await pump(t, build(militaryAt(2), 3));
      await t.tap(find.text('3').first);
      await t.pumpAndSettle();
      expect(find.text('Militaire · Niveau 3'), findsOneWidget);
      await t.tap(find.text('Rechercher'));
      await t.pumpAndSettle();
      expect(researched, TechBranch.military);
      expect(find.text('Militaire · Niveau 3'), findsNothing);
    });

    testWidgets('closing the popup leaves no highlight', (t) async {
      await pump(t, build(militaryAt(2), 3));
      final before = t.widget<Container>(
        find.ancestor(of: find.text('3').first, matching: find.byType(Container)).first);
      await t.tap(find.text('3').first);
      await t.pumpAndSettle();
      await t.tapAt(const Offset(195, 20));
      await t.pumpAndSettle();
      expect(find.text('Militaire · Niveau 3'), findsNothing);
      final after = t.widget<Container>(
        find.ancestor(of: find.text('3').first, matching: find.byType(Container)).first);
      expect(after.decoration, before.decoration);
    });

    testWidgets('tapping a branch opens a popup to unlock it', (t) async {
      await pump(t, build(militaryAt(2), 3));
      await t.tap(find.textContaining('Explorateur'));
      await t.pumpAndSettle();
      await t.tap(find.text('Débloquer'));
      await t.pumpAndSettle();
      expect(unlocked, TechBranch.explorer);
    });

    testWidgets('node above lab level shows the requirement', (t) async {
      await pump(t, build(militaryAt(3), 3));
      await t.tap(find.text('4').first);
      await t.pumpAndSettle();
      expect(find.text('Laboratoire niveau 4 requis'), findsOneWidget);
    });

    testWidgets('researched node shows acquired state', (t) async {
      await pump(t, build(militaryAt(2), 3));
      await t.tap(find.text('1').first);
      await t.pumpAndSettle();
      expect(find.text('Militaire · Niveau 1'), findsOneWidget);
      expect(find.text('Acquis \u2713'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });
  });
}
