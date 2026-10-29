import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/presentation/widgets/base/base_layout.dart';

void main() {
  const layout = BaseLayout.island;

  test('the island is a plateau of 12 by 12 cells', () {
    expect(layout.size, 12);
  });

  test('every building type has its place on the island', () {
    for (final type in BuildingType.values) {
      expect(layout.slots, contains(type), reason: '$type');
    }
    expect(layout.slotOf(BuildingType.headquarters).footprint, 3);
    expect(layout.slotOf(BuildingType.volcanicKernel).scale, 1.25);
  });

  test('no two footprints overlap, touching edges allowed', () {
    final types = BuildingType.values;
    for (var i = 0; i < types.length; i++) {
      for (var j = i + 1; j < types.length; j++) {
        final a = layout.slotOf(types[i]).bounds.deflate(1e-9);
        final b = layout.slotOf(types[j]).bounds.deflate(1e-9);
        expect(a.overlaps(b), isFalse, reason: '${types[i]} / ${types[j]}');
      }
    }
  });

  test('every footprint lies within the plateau', () {
    expect(layout.ground, const Rect.fromLTWH(0, 0, 12, 12));
    final plateau = layout.ground.inflate(1e-9);
    for (final type in BuildingType.values) {
      final bounds = layout.slotOf(type).bounds;
      expect(plateau.intersect(bounds), bounds, reason: '$type');
    }
  });

  test('the draw order lists every building from the back to the front', () {
    final order = layout.drawOrder;
    expect(order.toSet(), BuildingType.values.toSet());
    expect(order, hasLength(BuildingType.values.length));
    expect(order.first, BuildingType.volcanicKernel);
    expect(order.last, BuildingType.coralCitadel);
    for (var i = 1; i < order.length; i++) {
      expect(layout.slotOf(order[i - 1]).depth,
          lessThanOrEqualTo(layout.slotOf(order[i]).depth));
    }
  });

  test('the draw order breaks ties the same way every time', () {
    expect(layout.drawOrder, layout.drawOrder);
    final order = layout.drawOrder;
    expect(order.indexOf(BuildingType.laboratory),
        lessThan(order.indexOf(BuildingType.solarPanel)));
  });

  test('the ground under a slot centre belongs to its building', () {
    for (final type in BuildingType.values) {
      final slot = layout.slotOf(type);
      expect(layout.buildingAt(Offset(slot.u, slot.v)), type);
    }
  });

  test('empty ground belongs to no building', () {
    expect(layout.buildingAt(const Offset(0.5, 11.5)), isNull);
    expect(layout.buildingAt(const Offset(-1, -1)), isNull);
  });
}
