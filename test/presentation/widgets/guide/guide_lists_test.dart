import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/objective/guide/guide_target.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/building/building_card.dart';
import 'package:abyss/presentation/widgets/building/building_list_view.dart';
import 'package:abyss/presentation/widgets/unit/army_list_view.dart';
import 'package:abyss/presentation/widgets/unit/unit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';
import 'guide_widget_helpers.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  final player = Player(name: 'Nemo');

  Widget base(GuideTarget? target) => guidedApp(
    BuildingListView(
      buildings: player.buildings,
      resources: player.resources,
      worksite: player.worksite,
      onBuildingTap: (_) {},
    ),
    target,
  );

  Widget army(GuideTarget? target) => guidedApp(
    ArmyListView(
      unitsPerLevel: player.unitsPerLevel,
      barracksLevel: 1,
      buildings: player.buildings,
      onUnitTap: (_) {},
    ),
    target,
  );

  Finder buildingCard(BuildingType type) => find.byWidgetPredicate(
    (widget) => widget is BuildingCard && widget.building.type == type,
  );

  Finder unitCard(UnitType type) => find.byWidgetPredicate(
    (widget) => widget is UnitCard && widget.unitType == type,
  );

  testWidgets('the halo surrounds the card of the building to raise', (
    tester,
  ) async {
    await tester.pumpWidget(
      base(const GuideTarget.building(BuildingType.algaeFarm)),
    );
    await tester.pump();

    expect(activeHalos, findsOneWidget);
    expect(haloAround(buildingCard(BuildingType.algaeFarm)), findsOneWidget);
  });

  testWidgets('no halo on the base without a building to raise', (
    tester,
  ) async {
    await tester.pumpWidget(base(const GuideTarget.unit(UnitType.scout)));
    await tester.pumpAndSettle();

    expect(activeHalos, findsNothing);
  });

  testWidgets('the halo surrounds the card of the unit to recruit', (
    tester,
  ) async {
    await tester.pumpWidget(army(const GuideTarget.unit(UnitType.scout)));
    await tester.pump();

    expect(activeHalos, findsOneWidget);
    expect(haloAround(unitCard(UnitType.scout)), findsOneWidget);
  });

  testWidgets('no halo without a guide', (tester) async {
    await tester.pumpWidget(army(null));
    await tester.pumpAndSettle();

    expect(activeHalos, findsNothing);
  });
}
