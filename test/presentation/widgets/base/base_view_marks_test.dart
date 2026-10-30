import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/objective/guide/guide_target.dart';
import 'package:abyss/presentation/widgets/base/base_badge.dart';
import 'package:abyss/presentation/widgets/base/base_badges_painter.dart';
import 'package:abyss/presentation/widgets/base/base_view.dart';
import 'package:abyss/presentation/widgets/building/base_shield_badge.dart';
import 'package:abyss/presentation/widgets/building/worksite_badge.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/reduced_motion.dart';
import '../../../helpers/test_svg_helper.dart';
import '../guide/guide_widget_helpers.dart';

void main() {
  reduceMotionInEveryTest();
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Player player() => Player(name: 'Nemo')
    ..buildings[BuildingType.headquarters]!.level = 2
    ..buildings[BuildingType.algaeFarm]!.level = 1;

  Future<void> show(
    WidgetTester tester, {
    GuideTarget? target,
    Player? of,
    Set<BuildingType> upgradable = const {},
    Set<BuildingType> locked = const {},
  }) async {
    final nemo = of ?? player();
    await tester.pumpWidget(guidedApp(
      BaseView(
        buildings: nemo.buildings,
        worksite: nemo.worksite,
        onBuildingTap: (_) {},
        upgradable: upgradable,
        locked: locked,
      ),
      target,
    ));
    await tester.pump();
  }

  T painterOf<T>(WidgetTester tester) => tester
      .widgetList<CustomPaint>(find.byType(CustomPaint))
      .map((paint) => paint.painter)
      .whereType<T>()
      .single;

  testWidgets("the guided plot's name is written under its pill", (
    tester,
  ) async {
    await show(tester,
        target: const GuideTarget.building(BuildingType.barracks));
    final marks = painterOf<BaseBadgesPainter>(tester);
    expect(marks.guided, BuildingType.barracks);
    expect(marks.guidedName, 'Caserne');
    expect(marks.toBuild, 'À bâtir');
  });

  testWidgets('the marks show the chevrons and the locks they are given', (
    tester,
  ) async {
    await show(tester,
        upgradable: {BuildingType.algaeFarm},
        locked: {BuildingType.descentModule});
    final marks = painterOf<BaseBadgesPainter>(tester).snapshot;
    expect(marks.upgradable, {BuildingType.algaeFarm});
    expect(marks.locked, {BuildingType.descentModule});
    expect(marks.badgeOf(BuildingType.algaeFarm), BaseBadge.upgrade);
  });

  testWidgets('no rampart banner before the Coral Citadel is built', (
    tester,
  ) async {
    await show(tester);
    expect(find.byType(BaseShieldBadge), findsOneWidget);
    expect(find.textContaining('Rempart'), findsNothing);
  });

  testWidgets('the rampart banner lies under the worksites once built', (
    tester,
  ) async {
    await show(tester,
        of: player()..buildings[BuildingType.coralCitadel]!.level = 1);
    final rampart = find.textContaining('Rempart');
    expect(rampart, findsOneWidget);
    expect(tester.getRect(rampart).top,
        greaterThan(tester.getRect(find.byType(WorksiteBadge)).bottom));
  });

}
