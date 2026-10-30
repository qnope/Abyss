import 'package:abyss/presentation/widgets/base/base_slot.dart';
import 'package:abyss/presentation/widgets/base/base_slot_projection.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const plain = BaseSlot(u: 3, v: 1, footprint: 2, scale: 1);
  const tile = MapProjection.tileWidth;

  test('a ground point lands where the map projects it, and back', () {
    const ground = Offset(3, 1);
    final point = baseGroundToProjection(ground);
    expect(point, MapProjection.toScreen(ground * MapProjection.tileHeight));
    expect(point, const Offset(2 * tile / 2, 4 * tile / 4));
    expect(baseProjectionToGround(point), ground);
  });

  test('the foot of a slot is its projected centre', () {
    expect(plain.foot, baseGroundToProjection(const Offset(3, 1)));
  });

  test('a building stands on its foot at the size of the mockup', () {
    final box = plain.standingBox;
    expect(box.width, closeTo(2 * tile * 0.95 + 12, 1e-9));
    expect(box.height, box.width);
    expect(box.center.dx, closeTo(plain.foot.dx, 1e-9));
    expect(box.top + 0.86 * box.height, closeTo(plain.foot.dy, 1e-9));
  });

  test('the scale of a slot sizes its building', () {
    const big = BaseSlot(u: 3, v: 1, footprint: 2, scale: 1.25);
    expect(big.standingBox.width, closeTo(plain.standingBox.width * 1.25, 1e-9));
  });

  test('the footprint covers its cells on the screen', () {
    final box = plain.footprintBox;
    expect(box.center, plain.foot);
    expect(box.width, 2 * tile);
    expect(box.height, 2 * MapProjection.tileHeight);
    expect(plain.footprintDiamond.getBounds(), box);
    expect(plain.footprintDiamond.contains(plain.foot), isTrue);
  });

  test('the contact shadow lies flat under the building', () {
    final shadow = plain.shadowBox;
    expect(shadow.width, greaterThan(2 * shadow.height));
    expect(shadow.contains(plain.foot), isTrue);
    expect(shadow.width, lessThan(plain.standingBox.width));
  });
}
