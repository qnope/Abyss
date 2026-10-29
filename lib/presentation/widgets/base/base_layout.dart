import 'dart:ui';

import '../../../domain/building/building_type.dart';
import 'base_slot.dart';

/// The plan of a base: a square plateau of [size] by [size] cells where
/// each building type has its fixed [slots].
class BaseLayout {
  /// The side of the plateau, in cells.
  final int size;

  /// The place of every building type.
  final Map<BuildingType, BaseSlot> slots;

  const BaseLayout({required this.size, required this.slots});

  /// The island of the player's base, as drawn on the approved mockup.
  static const island = BaseLayout(size: 12, slots: {
    BuildingType.volcanicKernel:
        BaseSlot(u: 2.0, v: 2.0, footprint: 2, scale: 1.25),
    BuildingType.laboratory: BaseSlot(u: 2.2, v: 6.6, footprint: 2, scale: 1.0),
    BuildingType.solarPanel: BaseSlot(u: 6.6, v: 2.2, footprint: 2, scale: 1.0),
    BuildingType.coralMine: BaseSlot(u: 3.7, v: 9.0, footprint: 2, scale: 1.0),
    BuildingType.headquarters:
        BaseSlot(u: 6.4, v: 6.4, footprint: 3, scale: 1.05),
    BuildingType.algaeFarm: BaseSlot(u: 9.0, v: 3.7, footprint: 2, scale: 1.0),
    BuildingType.barracks: BaseSlot(u: 7.4, v: 10.4, footprint: 2, scale: 1.0),
    BuildingType.oreExtractor:
        BaseSlot(u: 10.4, v: 7.4, footprint: 2, scale: 1.0),
    BuildingType.pressureCapsule:
        BaseSlot(u: 4.6, v: 11.0, footprint: 2, scale: 0.95),
    BuildingType.descentModule:
        BaseSlot(u: 11.0, v: 4.6, footprint: 2, scale: 1.0),
    BuildingType.coralCitadel:
        BaseSlot(u: 10.2, v: 10.2, footprint: 2, scale: 1.05),
  });

  /// The plateau on the ground, in cells.
  Rect get ground => Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble());

  /// The place of [type].
  BaseSlot slotOf(BuildingType type) => slots[type]!;

  /// The building types from the back to the front of the base, by
  /// [BaseSlot.depth]; a tie goes to the smaller u, then to the type order.
  List<BuildingType> get drawOrder => slots.keys.toList()
    ..sort((a, b) {
      final sa = slotOf(a), sb = slotOf(b);
      final byDepth = sa.depth.compareTo(sb.depth);
      if (byDepth != 0) return byDepth;
      final byU = sa.u.compareTo(sb.u);
      return byU != 0 ? byU : a.index.compareTo(b.index);
    });

  /// The building whose footprint holds the ground [point], or `null` on
  /// empty ground.
  BuildingType? buildingAt(Offset point) {
    for (final MapEntry(:key, :value) in slots.entries) {
      if (value.contains(point)) return key;
    }
    return null;
  }
}
