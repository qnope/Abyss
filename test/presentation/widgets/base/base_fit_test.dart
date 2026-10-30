import 'dart:ui';

import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/presentation/widgets/base/base_fit.dart';
import 'package:abyss/presentation/widgets/base/base_layout.dart';
import 'package:abyss/presentation/widgets/base/base_slot_projection.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const layout = BaseLayout.island;
  const phone = Size(390, 635);
  final fit = BaseFit.of(phone, layout);

  Rect onScreen(Rect projection) => Rect.fromPoints(
        fit.toView(projection.topLeft),
        fit.toView(projection.bottomRight),
      );

  test('on a phone, a cell is as wide as on the mockup', () {
    expect(fit.tileWidth, closeTo(46, 1));
    expect(fit.zoom * MapProjection.tileWidth, fit.tileWidth);
  });

  test('the island is centred across the screen', () {
    final centre = baseGroundToProjection(const Offset(6, 6));
    expect(fit.toView(centre).dx, closeTo(phone.width / 2, 1e-9));
  });

  test('every footprint fits across the screen', () {
    for (final type in BuildingType.values) {
      final box = onScreen(layout.slotOf(type).footprintBox);
      expect(box.left, greaterThanOrEqualTo(0), reason: '$type');
      expect(box.right, lessThanOrEqualTo(phone.width), reason: '$type');
    }
  });

  test('every building stands under the badges', () {
    for (final type in BuildingType.values) {
      final box = onScreen(layout.slotOf(type).standingBox);
      expect(box.top, greaterThanOrEqualTo(BaseFit.badgeSpace),
          reason: '$type');
    }
  });

  test('the slab ends above the bottom of the screen', () {
    final corner = baseGroundToProjection(const Offset(12, 12));
    final slab = fit.toView(corner).dy + BaseFit.slabDepth * fit.zoom;
    expect(slab, lessThanOrEqualTo(phone.height));
  });

  test('a short wide screen fits the island to its height', () {
    const wide = Size(1200, 500);
    final short = BaseFit.of(wide, layout);
    final corner = baseGroundToProjection(const Offset(12, 12));
    expect(short.toView(corner).dy + BaseFit.slabDepth * short.zoom,
        lessThanOrEqualTo(wide.height + 1e-9));
    final top = layout.slotOf(BuildingType.volcanicKernel).standingBox.top;
    expect(short.toView(Offset(0, top)).dy,
        greaterThanOrEqualTo(BaseFit.badgeSpace - 1e-9));
    expect(short.toView(baseGroundToProjection(const Offset(6, 6))).dx, 600);
  });

  test('the view and the projection convert both ways', () {
    const point = Offset(-120, 340);
    final back = fit.toProjection(fit.toView(point));
    expect(back.dx, closeTo(point.dx, 1e-9));
    expect(back.dy, closeTo(point.dy, 1e-9));
  });

  test('fits of the same view are equal', () {
    expect(BaseFit.of(phone, layout), fit);
    expect(BaseFit.of(phone, layout).hashCode, fit.hashCode);
    expect(BaseFit.of(const Size(400, 635), layout), isNot(fit));
  });

  test('an island of another size, with no slot, fits its plateau', () {
    const parade = BaseLayout(size: 9, slots: {});
    final small = BaseFit.of(phone, parade);
    final left = small.toView(baseGroundToProjection(const Offset(0, 9)));
    final right = small.toView(baseGroundToProjection(const Offset(9, 0)));
    expect(left.dx, closeTo(0, 1e-9));
    expect(right.dx, closeTo(phone.width, 1e-9));
  });

  group('a plateau fitted around boxes', () {
    const w = MapProjection.tileWidth;
    final boxes = [
      const Rect.fromLTRB(-3 * w, w, -w, 2 * w),
      const Rect.fromLTRB(w, w, 2 * w, 2 * w),
    ];
    final around = BaseFit.around(phone,
        size: 9, across: boxes, under: [const Rect.fromLTRB(-w, -w, w, 0)]);

    test('keeps the widest box at an edge of the view', () {
      expect(around.toView(const Offset(-3 * w, 0)).dx, closeTo(0, 1e-9));
      expect(around.toView(const Offset(2 * w, 0)).dx,
          lessThanOrEqualTo(phone.width));
    });

    test('keeps the boxes under the badges', () {
      expect(around.toView(const Offset(0, -w)).dy,
          greaterThanOrEqualTo(BaseFit.badgeSpace - 1e-9));
    });

    test('is the fit of a layout given its slots', () {
      expect(
        BaseFit.around(phone,
            size: 12,
            across: [for (final s in layout.slots.values) s.footprintBox],
            under: [for (final s in layout.slots.values) s.standingBox]),
        fit,
      );
    });
  });
}
