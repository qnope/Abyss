import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/objective/guide/guide_target.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/army/army_guide_halo.dart';
import 'package:abyss/presentation/widgets/army/army_slots.dart';
import 'package:abyss/presentation/widgets/army/army_view.dart';
import 'package:abyss/presentation/widgets/base/base_guide_halo.dart';
import 'package:abyss/presentation/widgets/base/base_slot_projection.dart';
import 'package:abyss/presentation/widgets/guide/guide_halo.dart';
import 'package:abyss/presentation/widgets/base/base_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/army_taps.dart';
import '../../../helpers/reduced_motion.dart';
import '../../../helpers/test_svg_helper.dart';
import 'guide_widget_helpers.dart';

void main() {
  reduceMotionInEveryTest();
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  final player = Player(name: 'Nemo');

  Widget base(GuideTarget? target) => guidedApp(
    BaseView(
      buildings: player.buildings,
      worksite: player.worksite,
      onBuildingTap: (_) {},
    ),
    target,
  );

  Widget army(GuideTarget? target) => guidedApp(
    ArmyView(
      buildings: player.buildings,
      counts: const {UnitType.scout: 0},
      onUnitTap: (_) {},
    ),
    target,
  );

  Finder buildingSlot(BuildingType type) =>
      find.byKey(BaseGuideHalo.keyOf(type));

  Finder unitPad(UnitType type) => find.byKey(ArmyGuideHalo.keyOf(type));

  testWidgets('the halo surrounds the slot of the building to raise', (
    tester,
  ) async {
    await tester.pumpWidget(
      base(const GuideTarget.building(BuildingType.algaeFarm)),
    );
    await tester.pump();

    expect(activeHalos, findsOneWidget);
    expect(haloAround(buildingSlot(BuildingType.algaeFarm)), findsOneWidget);
  });

  testWidgets('no halo on the base without a building to raise', (
    tester,
  ) async {
    await tester.pumpWidget(base(const GuideTarget.unit(UnitType.scout)));
    await tester.pumpAndSettle();

    expect(activeHalos, findsNothing);
  });

  testWidgets('the halo surrounds the drill pad of the unit to recruit', (
    tester,
  ) async {
    await tester.pumpWidget(army(const GuideTarget.unit(UnitType.scout)));
    await tester.pump();

    expect(activeHalos, findsOneWidget);
    final halo = haloAround(unitPad(UnitType.scout));
    expect(halo, findsOneWidget);
    expect(tester.widget<GuideHalo>(halo).outline, BaseGuideHalo.diamondOf);
    final pad = ArmySlots.pad(UnitType.scout).foot;
    final centre = tester.getCenter(unitPad(UnitType.scout));
    expect((centre - armyPoint(tester, pad)).distance, lessThan(1));
  });

  testWidgets('no halo on the army without a unit to recruit', (
    tester,
  ) async {
    await tester.pumpWidget(
      army(const GuideTarget.building(BuildingType.barracks)),
    );
    await tester.pump();

    expect(activeHalos, findsNothing);
  });

  testWidgets('no halo without a guide', (tester) async {
    await tester.pumpWidget(army(null));
    await tester.pumpAndSettle();

    expect(activeHalos, findsNothing);
  });
}
