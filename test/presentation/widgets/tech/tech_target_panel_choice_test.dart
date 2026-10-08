import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_option.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/tech/tech_choice_row.dart';
import 'package:abyss/presentation/widgets/tech/tech_target.dart';
import 'package:abyss/presentation/widgets/tech/tech_target_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/tech_helpers.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  group('TechTargetPanel choice mode', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    late List<TechOption> acted;

    Future<void> pump(WidgetTester t, int level,
        {int researched = 1, List<TechOption> options = const [],
        bool researchDone = false}) {
      acted = [];
      t.view.physicalSize = const Size(600, 1000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      return t.pumpWidget(MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: TechTargetPanel(
              target: TechTarget(TechBranch.military, level),
              techBranches: techBranchesWith([
                researchedBranch(TechBranch.military, researched,
                    options: options),
              ]),
              buildings: {
                BuildingType.laboratory:
                    Building(type: BuildingType.laboratory, level: 5),
              },
              resources: {
                for (final t in ResourceType.values)
                  t: Resource(type: t, amount: 900, maxStorage: 1000),
              },
              researchDone: researchDone,
              onAct: acted.add,
            ),
          ),
        ),
      ));
    }

    testWidgets('a choice node offers two "Choisir" buttons', (t) async {
      await pump(t, 2);
      expect(find.byType(TechChoiceRow), findsOneWidget);
      expect(find.text('Militaire · Niveau 2 · Choix'), findsOneWidget);
      expect(find.text('Choisir'), findsNWidgets(2));
      expect(find.text('Rechercher'), findsNothing);
    });

    testWidgets('tapping an option acts with that option', (t) async {
      await pump(t, 2);
      await t.tap(find.text('Choisir').last);
      expect(acted, [TechOption.b]);
      await t.tap(find.text('Choisir').first);
      expect(acted, [TechOption.b, TechOption.a]);
    });

    testWidgets('a blocked choice disables both options', (t) async {
      await pump(t, 2, researchDone: true);
      final buttons =
          t.widgetList<ElevatedButton>(find.byType(ElevatedButton));
      expect(buttons, hasLength(2));
      expect(buttons.every((b) => b.onPressed == null), isTrue);
      expect(find.text('Une recherche par tour : attendez le prochain tour'),
          findsOneWidget);
    });

    testWidgets('a researched choice shows the option taken', (t) async {
      await pump(t, 4, researched: 4, options: [TechOption.a, TechOption.b]);
      expect(find.text('Choisi ✓'), findsOneWidget);
      expect(find.text('Écarté'), findsOneWidget);
      expect(find.text('Acquis ✓'), findsOneWidget);
      expect(find.text('Choisir'), findsNothing);
    });

    testWidgets('a tier node keeps a single "Rechercher" acting with A',
        (t) async {
      await pump(t, 3, researched: 2);
      expect(find.byType(TechChoiceRow), findsNothing);
      await t.tap(find.text('Rechercher'));
      expect(acted, [TechOption.a]);
    });
  });
}
