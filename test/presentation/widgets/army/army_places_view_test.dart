import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';
import 'package:abyss/presentation/widgets/army/army_place_bar.dart';
import 'package:abyss/presentation/widgets/army/army_places.dart';
import 'package:abyss/presentation/widgets/army/army_places_view.dart';
import 'package:abyss/presentation/widgets/army/army_squads_painter.dart';
import 'package:abyss/presentation/widgets/army/army_sprites.dart';
import 'package:abyss/presentation/widgets/army/army_view.dart';
import 'package:abyss/presentation/widgets/common/raster_paint.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/army_taps.dart';
import '../../../helpers/army_view_harness.dart';
import '../../../helpers/reduced_motion.dart';
import '../../../helpers/test_svg_helper.dart';
import '../guide/guide_widget_helpers.dart';

void main() {
  reduceMotionInEveryTest();
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  const scout = UnitType.scout, harpoonist = UnitType.harpoonist;
  const split = ArmyPlaces({
    1: {scout: 10},
    2: {scout: 4, harpoonist: 2},
    KernelGarrison.stockKey: {harpoonist: 5},
  });
  late List<(UnitType, int)> opened;

  Future<void> show(
    WidgetTester tester,
    ArmyPlaces places, {
    Set<UnitType> recruitable = const {scout},
  }) async {
    opened = [];
    await tester.runAsync(ArmySprites.load);
    final nemo = Player(name: 'Nemo')
      ..buildings[BuildingType.barracks]!.level = 1;
    await tester.pumpWidget(
      guidedApp(
        ArmyPlacesView(
          buildings: nemo.buildings,
          places: places,
          recruitable: recruitable,
          recruitPlace: 1,
          onUnitTap: (type, count) => opened.add((type, count)),
        ),
        null,
      ),
    );
    await tester.pump();
  }

  ArmyView view(WidgetTester tester) =>
      tester.widget<ArmyView>(find.byType(ArmyView));

  testWidgets('shows the places once the army serves in two of them', (
    tester,
  ) async {
    await show(tester, split);
    expect(find.byType(ArmyPlaceBar), findsOneWidget);
    expect(view(tester).bottomSpace, ArmyPlaceBar.room);
    expect(view(tester).counts, {scout: 14, harpoonist: 7});
  });

  testWidgets('hides the places of an army in one place, or none', (
    tester,
  ) async {
    for (final places in [
      const ArmyPlaces({
        1: {scout: 10},
        2: {scout: 0},
      }),
      const ArmyPlaces(),
    ]) {
      await show(tester, places);
      expect(find.byType(ArmyPlaceBar), findsNothing);
      expect(view(tester).bottomSpace, 0);
    }
  });

  testWidgets('a place leaves on the ground only the units it holds', (
    tester,
  ) async {
    await show(tester, split);
    await tester.tap(find.text('Niv. 2'));
    await tester.pump();
    final roster = painterOf<ArmySquadsPainter>(tester).roster;
    expect(roster.countOf(scout), 4);
    expect(roster.figuresOf(harpoonist), 2);
    await tester.tap(find.text('Niv. 1'));
    await tester.pump();
    final first = painterOf<ArmySquadsPainter>(tester).roster;
    expect(first.countOf(harpoonist), 0);
    expect(first.figuresOf(harpoonist), 0);
    expect(first.isLocked(UnitType.guardian), isTrue);
  });

  testWidgets('the « + » shows under all and where recruits arrive', (
    tester,
  ) async {
    await show(tester, split);
    expect(view(tester).recruitable, {scout});
    await tester.tap(find.text('Niv. 2'));
    await tester.pump();
    expect(view(tester).recruitable, isEmpty);
    await tester.tap(find.text('Niv. 1'));
    await tester.pump();
    expect(view(tester).recruitable, {scout});
  });

  testWidgets('a squad opens with the count of the place shown', (
    tester,
  ) async {
    await show(tester, split);
    await tapDrillPad(tester, harpoonist);
    await tester.tap(find.text('Noyau'));
    await tester.pump();
    await tapDrillPad(tester, harpoonist);
    await tapDrillPad(tester, scout);
    expect(opened, [(harpoonist, 7), (harpoonist, 5), (scout, 0)]);
  });

  testWidgets('changing place repaints the squads, never the island',
      (tester) async {
    await show(tester, split);
    await tester.tap(find.text('Niv. 2'));
    await tester.pump(Duration.zero, EnginePhase.layout);
    expect(tester.renderObject(find.byType(RasterPaint)).debugNeedsPaint,
        isFalse);
    expect(tester.renderObject(find.byWidgetPredicate((widget) =>
        widget is CustomPaint && widget.painter is ArmySquadsPainter))
        .debugNeedsPaint, isTrue);
    await tester.pump();
  });

  testWidgets('back to all once the place shown is left empty',
      (tester) async {
    await show(tester, split);
    await tester.tap(find.text('Noyau'));
    await tester.pump();
    await show(tester, const ArmyPlaces({1: {scout: 10}, 2: {harpoonist: 7}}));
    expect(view(tester).counts, {scout: 10, harpoonist: 7});
  });
}
