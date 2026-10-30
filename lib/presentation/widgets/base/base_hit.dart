import 'dart:ui';

import '../../../domain/building/building_type.dart';
import '../map/map_standing_hit.dart';
import 'base_layout.dart';
import 'base_slot_projection.dart';

/// The building of [layout] under the projection [point]: the front-most
/// whose sprite stands there, as a sprite overlaps the slots behind its
/// own; else the one whose footprint lies there; `null` on empty ground.
BuildingType? baseBuildingAt(Offset point, BaseLayout layout) {
  final order = layout.drawOrder;
  for (var k = order.length - 1; k >= 0; k--) {
    final type = order[k];
    final box = layout.slotOf(type).standingBox;
    if (standingHitBox(box).contains(point)) return type;
  }
  return layout.buildingAt(baseProjectionToGround(point));
}
