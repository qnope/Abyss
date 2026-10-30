import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/presentation/widgets/base/base_badge_geometry.dart';
import 'package:abyss/presentation/widgets/base/base_layout.dart';
import 'package:abyss/presentation/widgets/base/base_pad_geometry.dart';
import 'package:abyss/presentation/widgets/base/base_pad_tier.dart';
import 'package:abyss/presentation/widgets/base/base_slot.dart';
import 'package:abyss/presentation/widgets/base/base_slot_projection.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final farm = BaseLayout.island.slotOf(BuildingType.algaeFarm);

  group('the level plaque', () {
    test('sits on the lower left of a built sprite, on its ground', () {
      final box = farm.standingBoxOn(BasePadTier.gravel);
      final at = farm.plaqueAt(2);
      expect(at.dx, closeTo(box.center.dx - 0.3 * box.width, 1e-9));
      expect(at.dy, closeTo(farm.foot.dy - 0.1 * box.width, 1e-9));
    });

    test('follows the sprite as its pad grows', () {
      final low = farm.standingBoxOn(BasePadTier.gravel);
      final high = farm.standingBoxOn(BasePadTier.litDeck);
      expect(farm.plaqueAt(9).dx - farm.plaqueAt(1).dx,
          closeTo(high.center.dx - low.center.dx, 1e-9));
    });

    test('a plot shows its pill at the centre of its ground', () {
      final at = farm.plaqueAt(0);
      expect(at.dx, farm.foot.dx);
      expect(at.dy, lessThan(farm.foot.dy));
      expect(farm.footprintBox.contains(at), isTrue);
    });
  });

  test('the chevron or the triangle floats on the upper right', () {
    final box = farm.standingBoxOn(BasePadTier.deck);
    final at = farm.badgeAt(5);
    expect(at.dx, closeTo(box.center.dx + 0.3 * box.width, 1e-9));
    expect(at.dy, closeTo(box.top + 0.2 * box.width, 1e-9));
  });

  test('the badge of a bigger building floats higher', () {
    const small = BaseSlot(u: 4, v: 4, footprint: 2, scale: 1);
    const big = BaseSlot(u: 4, v: 4, footprint: 2, scale: 1.25);
    expect(big.badgeAt(1).dy, lessThan(small.badgeAt(1).dy));
  });

  test("the guide's ring surrounds the footprint, a little outside", () {
    final ring = farm.ringBox;
    final footprint = farm.footprintBox;
    expect(ring.center, farm.foot);
    expect(ring.width / ring.height,
        closeTo(MapProjection.tileWidth / MapProjection.tileHeight, 1e-9));
    expect(ring.width, greaterThan(footprint.width));
    expect(ring.contains(footprint.topLeft) && ring.contains(footprint.bottomRight),
        isTrue);
  });

  test("the ring's corners are the four tips of its diamond", () {
    final ring = farm.ringBox;
    expect(farm.ringCorners, [
      ring.topCenter,
      ring.centerRight,
      ring.bottomCenter,
      ring.centerLeft,
    ]);
  });
}
