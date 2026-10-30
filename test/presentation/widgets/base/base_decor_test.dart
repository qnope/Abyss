import 'dart:ui';

import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/presentation/widgets/base/base_decor.dart';
import 'package:abyss/presentation/widgets/base/base_layout.dart';
import 'package:abyss/presentation/widgets/base/base_rampart.dart';
import 'package:abyss/presentation/widgets/base/base_slot_projection.dart';
import 'package:abyss/presentation/widgets/base/base_walkway_drawer.dart';
import 'package:abyss/presentation/widgets/base/base_walkways.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const layout = BaseLayout.island;
  final decor = baseDecorOf(layout);

  /// The ground point, in cells, [decor] stands on.
  Offset groundOf(MapDecor decor) => baseProjectionToGround(decor.foot);

  test('stands a few decor between the slots', () {
    expect(decor.length, greaterThanOrEqualTo(8));
  });

  test('never stands on a footprint', () {
    for (final item in decor) {
      final ground = groundOf(item);
      for (final MapEntry(:key, :value) in layout.slots.entries) {
        expect(value.bounds.contains(ground), isFalse,
            reason: '$item on $key');
      }
    }
  });

  test('never stands on a walkway, whatever is built', () {
    final legs = baseWalkways(layout, BuildingType.values);
    for (final item in decor) {
      final ground = groundOf(item);
      for (final (from, to) in legs) {
        final band = Rect.fromPoints(from, to)
            .inflate(BaseWalkwayDrawer.standardWidth / 2);
        expect(band.contains(ground), isFalse, reason: '$item on a walkway');
      }
    }
  });

  test('keeps the rim free for the rampart', () {
    const rampart = BaseRampart.inset + BaseRampart.thickness;
    for (final item in decor) {
      final ground = groundOf(item);
      expect(layout.ground.deflate(rampart).contains(ground), isTrue,
          reason: '$item on the rim');
    }
  });

  test('never stands in front of a building over what it draws', () {
    for (final item in decor) {
      for (final type in BuildingType.values) {
        final slot = layout.slotOf(type);
        if (item.foot.dy <= slot.foot.dy) continue;
        expect(item.body.overlaps(baseStandingReach(slot)), isFalse,
            reason: '$item before $type');
      }
    }
  });

  test('is the same each time, and another salt scatters other decor', () {
    expect(listEquals(baseDecorOf(layout), decor), isTrue);
    expect(listEquals(baseDecorOf(layout, salt: 99), decor), isFalse);
  });

  test('is smaller than the map decor and drawn back to front', () {
    for (var k = 1; k < decor.length; k++) {
      expect(decor[k].foot.dy, greaterThanOrEqualTo(decor[k - 1].foot.dy));
    }
    for (final kind in baseDecorKinds) {
      final map = SeabedDecor.all.firstWhere((k) => k.svgPath == kind.svgPath);
      expect(kind.sizeRatio, lessThan(map.sizeRatio));
    }
  });

  test('scatters decor on an empty 9 by 9 parade ground', () {
    const parade = BaseLayout(size: 9, slots: {});
    expect(baseDecorOf(parade), isNotEmpty);
  });
}
