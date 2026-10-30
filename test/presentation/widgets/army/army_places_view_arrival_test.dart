import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/army/army_places.dart';
import 'package:abyss/presentation/widgets/army/army_places_view.dart';
import 'package:abyss/presentation/widgets/army/army_squads_painter.dart';
import 'package:abyss/presentation/widgets/army/army_sprites.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/army_view_harness.dart';
import '../../../helpers/test_svg_helper.dart';
import '../guide/guide_widget_helpers.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  const scout = UnitType.scout;
  ArmyPlaces split(int first, int second) => ArmyPlaces({
        1: {scout: first},
        2: {scout: second},
      });

  Future<void> show(WidgetTester tester, ArmyPlaces places) async {
    await tester.runAsync(ArmySprites.load);
    final nemo = Player(name: 'Nemo')
      ..buildings[BuildingType.barracks]!.level = 1;
    await tester.pumpWidget(guidedApp(
      ArmyPlacesView(
        buildings: nemo.buildings,
        places: places,
        recruitPlace: 1,
        onUnitTap: (_, _) {},
      ),
      null,
    ));
    await tester.pump(const Duration(milliseconds: 100));
  }

  Map<UnitType, Object> arriving(WidgetTester tester) =>
      painterOf<ArmySquadsPainter>(tester).arriving;

  testWidgets('changing place brings no recruit', (tester) async {
    await show(tester, split(2, 10));
    await tester.tap(find.text('Niv. 2'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(arriving(tester), isEmpty);
    await tester.tap(find.text('Toutes'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(arriving(tester), isEmpty);
  });

  testWidgets('recruits arrive where they are counted', (tester) async {
    await show(tester, split(2, 10));
    await show(tester, split(7, 10));
    expect(arriving(tester).keys, [scout]);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Niv. 2'));
    await tester.pump(const Duration(milliseconds: 100));
    await show(tester, split(12, 10));
    expect(arriving(tester), isEmpty);
  });
}
