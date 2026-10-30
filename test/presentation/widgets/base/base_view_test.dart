import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/objective/guide/guide_target.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/ambience/ambience_clock_scope.dart';
import 'package:abyss/presentation/widgets/base/base_badge_geometry.dart';
import 'package:abyss/presentation/widgets/base/base_fit.dart';
import 'package:abyss/presentation/widgets/base/base_guide_halo.dart';
import 'package:abyss/presentation/widgets/base/base_layout.dart';
import 'package:abyss/presentation/widgets/base/base_view.dart';
import 'package:abyss/presentation/widgets/building/worksite_badge.dart';
import 'package:abyss/presentation/widgets/guide/guide_halo.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/base_taps.dart';
import '../../../helpers/reduced_motion.dart';
import '../../../helpers/test_svg_helper.dart';
import '../guide/guide_widget_helpers.dart';

void main() {
  reduceMotionInEveryTest();
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  late List<Building> tapped;

  Player player() => Player(name: 'Nemo')
    ..buildings[BuildingType.headquarters]!.level = 2
    ..buildings[BuildingType.algaeFarm]!.level = 1;

  Future<Player> show(WidgetTester tester, {GuideTarget? target}) async {
    tapped = [];
    final nemo = player();
    await tester.pumpWidget(guidedApp(
      BaseView(
        buildings: nemo.buildings,
        worksite: nemo.worksite,
        onBuildingTap: tapped.add,
      ),
      target,
    ));
    await tester.pump();
    return nemo;
  }

  testWidgets('shows the worksite badge over the island', (tester) async {
    await show(tester);
    expect(find.byType(BaseView), findsOneWidget);
    expect(find.byType(WorksiteBadge), findsOneWidget);
    expect(find.byType(AmbienceClockScope), findsOneWidget);
  });

  testWidgets('touching where a building stands opens it', (tester) async {
    final nemo = await show(tester);
    await tapBuilding(tester, BuildingType.headquarters);
    expect(tapped, [nemo.buildings[BuildingType.headquarters]]);
  });

  testWidgets('a building still to build can be touched too', (tester) async {
    final nemo = await show(tester);
    expect(nemo.buildings[BuildingType.coralCitadel]!.level, 0);
    await tapBuilding(tester, BuildingType.coralCitadel);
    expect(tapped, [nemo.buildings[BuildingType.coralCitadel]]);
  });

  testWidgets('every building can be touched', (tester) async {
    final nemo = await show(tester);
    for (final type in BuildingType.values) {
      await tapBuilding(tester, type);
    }
    expect(tapped, [for (final t in BuildingType.values) nemo.buildings[t]]);
  });

  testWidgets('touching the water around the island opens nothing', (
    tester,
  ) async {
    await show(tester);
    final view = tester.getRect(find.byType(BaseView));
    await tester.tapAt(view.bottomLeft + const Offset(4, -4));
    expect(tapped, isEmpty);
  });

  testWidgets('the guide rings the slot of the building to raise', (
    tester,
  ) async {
    await show(tester,
        target: const GuideTarget.building(BuildingType.algaeFarm));
    expect(activeHalos, findsOneWidget);
    final slot = find.byKey(BaseGuideHalo.keyOf(BuildingType.algaeFarm));
    expect(haloAround(slot), findsOneWidget);
    final view = tester.getRect(find.byType(BaseView));
    final fit = BaseFit.of(view.size, BaseLayout.island);
    final ring = BaseLayout.island.slotOf(BuildingType.algaeFarm).ringBox;
    final rect = tester.getRect(slot);
    expect(rect.topLeft,
        offsetMoreOrLessEquals(view.topLeft + fit.toView(ring.topLeft)));
    expect(rect.bottomRight,
        offsetMoreOrLessEquals(view.topLeft + fit.toView(ring.bottomRight)));
    final halo = tester.widget<GuideHalo>(haloAround(slot));
    expect(halo.outline, BaseGuideHalo.diamondOf);
  });

  testWidgets('no halo on the base when the guide points elsewhere', (
    tester,
  ) async {
    await show(tester, target: const GuideTarget.unit(UnitType.scout));
    expect(activeHalos, findsNothing);
  });
}
