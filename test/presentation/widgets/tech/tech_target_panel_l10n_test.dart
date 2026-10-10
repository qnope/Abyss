import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_option.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/widgets/tech/tech_target.dart';
import 'package:abyss/presentation/widgets/tech/tech_target_panel.dart';
import 'package:abyss/presentation/widgets/tech/tech_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/localized_app.dart';
import '../../../helpers/tech_helpers.dart';
import '../../../helpers/test_svg_helper.dart';

/// The popup of [target] in [locale], with the military branch
/// researched up to [researched] (`null`: locked) and a laboratory of
/// [labLevel].
Future<void> _pump(
  WidgetTester t,
  Locale locale,
  TechTarget target, {
  int? researched,
  int labLevel = 5,
  List<TechOption> options = const [],
  bool researchDone = false,
}) {
  t.view.physicalSize = const Size(600, 1000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  return t.pumpWidget(localizedApp(
    locale: locale,
    Scaffold(
      body: SingleChildScrollView(
        child: TechTargetPanel(
          target: target,
          techBranches: techBranchesWith([
            if (researched != null)
              researchedBranch(TechBranch.military, researched,
                  options: options),
          ]),
          buildings: {
            BuildingType.laboratory:
                Building(type: BuildingType.laboratory, level: labLevel),
          },
          resources: {
            for (final t in ResourceType.values)
              t: Resource(type: t, amount: 900, maxStorage: 1000),
          },
          researchDone: researchDone,
          onAct: (_) {},
        ),
      ),
    ),
  ));
}

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('a choice node in English', (t) async {
    await _pump(t, AbyssLocale.en, const TechTarget(TechBranch.military, 2),
        researched: 1);
    expect(find.text('Military · Level 2 · Choice'), findsOneWidget);
    expect(find.text('Only one option per game, the other will be lost.'),
        findsOneWidget);
    expect(find.text('or'), findsOneWidget);
    expect(find.text('Choose'), findsNWidgets(2));
  });

  testWidgets('a choice already made in Spanish', (t) async {
    await _pump(t, AbyssLocale.es, const TechTarget(TechBranch.military, 2),
        researched: 2, options: const [TechOption.a]);
    expect(find.text('Elegida ✓'), findsOneWidget);
    expect(find.text('Descartada'), findsOneWidget);
    expect(find.text('Adquirido ✓'), findsOneWidget);
  });

  testWidgets('a locked branch in English', (t) async {
    await _pump(t, AbyssLocale.en, const TechTarget(TechBranch.military, 1));
    expect(find.text('Unlock the branch first'), findsOneWidget);
    expect(find.text('Research'), findsOneWidget);
  });

  testWidgets('a branch to unlock in Spanish', (t) async {
    await _pump(t, AbyssLocale.es, const TechTarget(TechBranch.military),
        labLevel: 0);
    expect(find.text('Desbloquear'), findsOneWidget);
    expect(find.textContaining('Laboratorio nivel'), findsOneWidget);
  });

  testWidgets('a node behind its previous level in Spanish', (t) async {
    await _pump(t, AbyssLocale.es, const TechTarget(TechBranch.military, 3),
        researched: 1, options: const [TechOption.a]);
    expect(find.text('Investiga primero el nivel 2'), findsOneWidget);
  });

  testWidgets('one research per turn in English', (t) async {
    await _pump(t, AbyssLocale.en, const TechTarget(TechBranch.military, 1),
        researched: 0, researchDone: true);
    expect(find.text('One research per turn: wait for the next turn'),
        findsOneWidget);
  });

  testWidgets('the reef tells the level of a branch in English', (t) async {
    t.view.physicalSize = const Size(390, 1100);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(localizedApp(
      locale: AbyssLocale.en,
      Scaffold(
        body: TechTreeView(
          techBranches: techBranchesWith(
              [researchedBranch(TechBranch.military, 1)]),
          buildings: const {},
          resources: const {},
          onUnlock: (_) {},
          onResearch: (_, _) {},
        ),
      ),
    ));
    await t.pumpAndSettle();
    expect(find.text('Military\nLv. 1'), findsOneWidget);
  });
}
