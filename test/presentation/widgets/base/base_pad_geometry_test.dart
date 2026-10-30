import 'package:abyss/presentation/widgets/base/base_pad_geometry.dart';
import 'package:abyss/presentation/widgets/base/base_pad_tier.dart';
import 'package:abyss/presentation/widgets/base/base_slot.dart';
import 'package:abyss/presentation/widgets/base/base_slot_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const slot = BaseSlot(u: 4, v: 6, footprint: 2, scale: 1);
  const inset = BasePadGeometry.padInset;

  test('the plot follows the footprint, a little inside it', () {
    const h = 1 - inset;
    expect(slot.padCorners, [
      baseGroundToProjection(const Offset(4 - h, 6 - h)),
      baseGroundToProjection(const Offset(4 + h, 6 - h)),
      baseGroundToProjection(const Offset(4 + h, 6 + h)),
      baseGroundToProjection(const Offset(4 - h, 6 + h)),
    ]);
  });

  test('a stake stands at each of the four corners', () {
    final stakes = slot.stakeTips;
    expect(stakes, hasLength(4));
    for (var k = 0; k < 4; k++) {
      final corner = slot.padCorners[k];
      expect(stakes[k].dx, corner.dx);
      expect(stakes[k].dy, lessThan(corner.dy));
    }
  });

  test('the top of the pad is lifted by its tier', () {
    for (final tier in BasePadTier.values) {
      final top = slot.padTop(tier);
      for (var k = 0; k < 4; k++) {
        expect(top[k], slot.padCorners[k].translate(0, -tier.lift));
      }
    }
  });

  test('a building stands on top of its pad', () {
    for (final tier in BasePadTier.values) {
      expect(
        slot.standingBoxOn(tier),
        slot.standingBox.translate(0, -tier.lift),
      );
      expect(slot.shadowBoxOn(tier), slot.shadowBox.translate(0, -tier.lift));
    }
    expect(
      slot.standingBoxOn(BasePadTier.litDeck).bottom,
      lessThan(slot.standingBoxOn(BasePadTier.gravel).bottom),
    );
  });

  test('bubbles rise from the upper part of a building, right of its middle',
      () {
    for (final tier in BasePadTier.values) {
      final sprite = slot.standingBoxOn(tier);
      final bubbles = slot.bubblesBoxOn(tier);
      expect(bubbles.center.dx, greaterThan(sprite.center.dx));
      expect(bubbles.bottom, lessThan(sprite.center.dy));
      expect(bubbles.top, lessThan(sprite.top));
    }
  });
}
