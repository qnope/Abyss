import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/unit/unit_cost_calculator.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/army/army_island_painter.dart';
import 'package:abyss/presentation/widgets/army/army_layout.dart';
import 'package:abyss/presentation/widgets/army/army_view.dart';
import 'package:abyss/presentation/widgets/building/base_shield_badge.dart';
import 'package:abyss/presentation/widgets/common/raster_paint.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/army_taps.dart';
import '../../../helpers/reduced_motion.dart';
import '../../../helpers/test_svg_helper.dart';
import '../guide/guide_widget_helpers.dart';

void main() {
  reduceMotionInEveryTest();
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  late List<UnitType> tapped;

  Future<Player> show(WidgetTester tester, {int barracks = 3}) async {
    tapped = [];
    final nemo = Player(name: 'Nemo')
      ..buildings[BuildingType.barracks]!.level = barracks
      ..buildings[BuildingType.coralCitadel]!.level = 1;
    await tester.pumpWidget(guidedApp(
      ArmyView(buildings: nemo.buildings, onUnitTap: tapped.add),
      null,
    ));
    await tester.pump();
    return nemo;
  }

  Finder rasters() => find.descendant(
      of: find.byType(ArmyView), matching: find.byType(RasterPaint));

  testWidgets('shows the still island as one kept bitmap', (tester) async {
    await show(tester);
    expect(rasters(), findsOneWidget);
    expect(tester.widget<RasterPaint>(rasters()).keepAs, ArmyView.islandName);
  });

  testWidgets('nothing on the still island moves', (tester) async {
    await show(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('lays the pad of each unit the barracks unlocks',
      (tester) async {
    await show(tester, barracks: 2);
    final painter =
        tester.widget<RasterPaint>(rasters()).painter as ArmyIslandPainter;
    expect(painter.barracksLevel, 2);
    expect(painter.unlocked, {
      for (final type in UnitType.values)
        if (UnitCostCalculator().isUnlocked(type, 2)) type,
    });
  });

  testWidgets('shows the rampart\'s badge at the top', (tester) async {
    await show(tester);
    expect(find.byType(BaseShieldBadge), findsOneWidget);
  });

  testWidgets('touching a drill pad opens its unit, locked or not',
      (tester) async {
    await show(tester, barracks: 1);
    for (final type in UnitType.values) {
      await tapDrillPad(tester, type);
    }
    expect(tapped, UnitType.values);
  });

  testWidgets('touching the crest or the depot opens nothing', (tester) async {
    await show(tester);
    await tester.tapAt(armySpot(tester, ArmyLayout.crest));
    await tester.tapAt(armySpot(tester, ArmyLayout.depot));
    expect(tapped, isEmpty);
  });
}
