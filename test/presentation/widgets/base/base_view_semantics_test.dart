import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/presentation/widgets/base/base_buildings_painter.dart';
import 'package:abyss/presentation/widgets/base/base_island_painter.dart';
import 'package:abyss/presentation/widgets/base/base_pad_tier.dart';
import 'package:abyss/presentation/widgets/base/base_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/reduced_motion.dart';
import '../../../helpers/test_svg_helper.dart';
import '../guide/guide_widget_helpers.dart';

void main() {
  reduceMotionInEveryTest();
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  const hq = BuildingType.headquarters, farm = BuildingType.algaeFarm;
  late List<Building> tapped;

  /// The base of a player whose farm (level 3) outgrew its QG (level 2).
  Future<Player> show(
    WidgetTester tester, {
    Set<BuildingType> upgradable = const {},
  }) async {
    tapped = [];
    final nemo =
        Player(name: 'Nemo')
          ..buildings[hq]!.level = 2
          ..buildings[farm]!.level = 3;
    await tester.pumpWidget(
      guidedApp(
        BaseView(
          buildings: nemo.buildings,
          worksite: nemo.worksite,
          onBuildingTap: tapped.add,
          upgradable: upgradable,
        ),
        null,
      ),
    );
    await tester.pump();
    return nemo;
  }

  T painterOf<T>(WidgetTester tester) =>
      tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((paint) => paint.painter)
          .whereType<T>()
          .single;

  testWidgets('the degraded buildings reach the painter', (tester) async {
    await show(tester);
    expect(painterOf<BaseBuildingsPainter>(tester).snapshot.degraded, {farm});
  });

  testWidgets('the still island lays every pad at its tier', (tester) async {
    await show(tester);
    final tiers = painterOf<BaseIslandPainter>(tester).tiers;
    expect(tiers[hq], BasePadTier.gravel);
    expect(tiers[farm], BasePadTier.gravel);
    expect(tiers[BuildingType.barracks], BasePadTier.plot);
  });

  testWidgets('every building is named for a screen reader', (tester) async {
    final semantics = tester.ensureSemantics();
    await show(tester);
    expect(find.bySemanticsLabel('Quartier Général, Niveau 2'), findsOneWidget);
    expect(
      find.bySemanticsLabel("Ferme d'algues, Niveau 3, Dégradé"),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Caserne, Non construit'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'^.+, (Niveau \d+|Non construit)')),
      findsNWidgets(BuildingType.values.length),
    );
    semantics.dispose();
  });

  testWidgets('a building that can rise now is said to be upgradable', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await show(tester, upgradable: {hq, farm});
    expect(
      find.bySemanticsLabel('Quartier Général, Niveau 2, Améliorable'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel("Ferme d'algues, Niveau 3, Dégradé"),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('a screen reader opens the building it names', (tester) async {
    final semantics = tester.ensureSemantics();
    final nemo = await show(tester);
    tester.semantics.tap(find.semantics.byLabel('Caserne, Non construit'));
    tester.semantics.tap(find.semantics.byLabel('Quartier Général, Niveau 2'));
    expect(tapped, [nemo.buildings[BuildingType.barracks], nemo.buildings[hq]]);
    semantics.dispose();
  });
}
