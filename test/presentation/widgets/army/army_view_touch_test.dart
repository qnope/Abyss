import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/army/army_squad_geometry.dart';
import 'package:abyss/presentation/widgets/map/map_standing_hit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/army_taps.dart';
import '../../../helpers/army_view_harness.dart';
import '../../../helpers/reduced_motion.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  reduceMotionInEveryTest();
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  late ArmyViewHarness army;
  setUp(() => army = ArmyViewHarness());

  testWidgets('touching a figure above its pad opens its unit',
      (tester) async {
    await army.show(tester, counts: {UnitType.harpoonist: 61});
    final feet =
        ArmySquadGeometry.feetOf(UnitType.harpoonist, 6, locked: false);
    final head = standingHitBox(ArmySquadGeometry.figureBox(feet.first));
    await tester.tapAt(
        armyPoint(tester, Offset(head.center.dx, head.top + 4)));
    expect(army.tapped, [UnitType.harpoonist]);
  });

  testWidgets('touching the barracks opens it, built or not', (tester) async {
    for (final level in [3, 0]) {
      await army.show(tester, barracks: level);
      await tapBarracks(tester, level);
    }
    final barracks = army.nemo.buildings[BuildingType.barracks];
    expect(army.opened, [barracks, barracks]);
    expect(army.tapped, isEmpty);
  });

  testWidgets('each squad and the barracks are named for a screen reader',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await army.show(tester,
        barracks: 2,
        counts: {UnitType.harpoonist: 22, UnitType.scout: 1},
        recruitable: {UnitType.harpoonist, UnitType.guardian});
    for (final label in [
      'Harponneurs, 22 unités, recrutable',
      'Éclaireur, 1 unité',
      'Amiraux des abysses, 0 unité',
      'Gardien, verrouillé, Caserne niveau 3',
      'Saboteur, verrouillé, Caserne niveau 5',
      'Caserne, Niveau 2',
    ]) {
      expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
    }
    semantics.dispose();
  });

  testWidgets('a screen reader opens the squad or the barracks it names',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await army.show(tester, barracks: 2);
    tester.semantics.tap(
        find.semantics.byLabel('Gardien, verrouillé, Caserne niveau 3'));
    tester.semantics.tap(find.semantics.byLabel('Caserne, Niveau 2'));
    expect(army.tapped, [UnitType.guardian]);
    expect(army.opened, [army.nemo.buildings[BuildingType.barracks]]);
    semantics.dispose();
  });
}
