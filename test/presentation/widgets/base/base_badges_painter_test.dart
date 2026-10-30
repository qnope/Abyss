import 'dart:ui';

import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/presentation/widgets/base/base_badges_painter.dart';
import 'package:abyss/presentation/widgets/base/base_fit.dart';
import 'package:abyss/presentation/widgets/base/base_layout.dart';
import 'package:abyss/presentation/widgets/base/base_pad_tier.dart';
import 'package:abyss/presentation/widgets/base/base_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const layout = BaseLayout.island;
  const view = Size(390, 635);
  final fit = BaseFit.of(view, layout);
  const hq = BuildingType.headquarters, farm = BuildingType.algaeFarm;
  const lab = BuildingType.laboratory, mine = BuildingType.coralMine;

  BaseSnapshot snapshot({
    int farmLevel = 1,
    Set<BuildingType> upgradable = const {},
    Set<BuildingType> degraded = const {},
    Set<BuildingType> locked = const {},
  }) {
    final levels = {hq: 2, farm: farmLevel, lab: 0, mine: 0};
    return BaseSnapshot(
      levels: levels,
      tiers: levels.map((t, l) => MapEntry(t, BasePadTier.ofLevel(l))),
      degraded: degraded,
      upgradable: upgradable,
      locked: locked,
    );
  }

  BaseBadgesPainter painter(BaseSnapshot base,
          {BuildingType? guided, String? guidedName}) =>
      BaseBadgesPainter(
        layout: layout,
        fit: fit,
        snapshot: base,
        toBuild: 'À bâtir',
        guided: guided,
        guidedName: guidedName,
      );

  test('paints every plaque, pill, lock, badge and the guided name', () {
    final recorder = PictureRecorder();
    painter(
      snapshot(upgradable: {hq}, degraded: {farm}, locked: {mine}),
      guided: lab,
      guidedName: 'Laboratoire',
    ).paint(Canvas(recorder), view);
    recorder.endRecording().dispose();
  });

  test('the same marks are not repainted', () {
    expect(
      painter(snapshot(upgradable: {hq}))
          .shouldRepaint(painter(snapshot(upgradable: {hq}))),
      isFalse,
    );
  });

  test('a level, a chevron, a lock or a triangle repaints the marks', () {
    final before = painter(snapshot());
    expect(painter(snapshot(farmLevel: 2)).shouldRepaint(before), isTrue);
    expect(painter(snapshot(upgradable: {hq})).shouldRepaint(before), isTrue);
    expect(painter(snapshot(locked: {lab})).shouldRepaint(before), isTrue);
    expect(painter(snapshot(degraded: {farm})).shouldRepaint(before), isTrue);
  });

  test('the guide pointing elsewhere repaints the marks', () {
    expect(
      painter(snapshot(), guided: lab, guidedName: 'Laboratoire')
          .shouldRepaint(painter(snapshot())),
      isTrue,
    );
  });

  test('the marks take no touch', () {
    expect(painter(snapshot()).hitTest(Offset.zero), isFalse);
  });
}
