import 'dart:ui';

import '../../../domain/building/building_type.dart';
import '../map/map_standing_hit.dart';
import 'base_layout.dart';
import 'base_pad_geometry.dart';
import 'base_pad_tier.dart';
import 'base_slot_projection.dart';

/// The building of [layout] under the projection [point]: the front-most
/// whose sprite stands there, on its pad at its tier in [tiers] (a plot
/// by default), as a sprite overlaps the slots behind its own; else the
/// one whose footprint lies there; `null` on empty ground.
BuildingType? baseBuildingAt(Offset point, BaseLayout layout,
    {Map<BuildingType, BasePadTier> tiers = const {}}) {
  final order = layout.drawOrder;
  for (var k = order.length - 1; k >= 0; k--) {
    final type = order[k];
    final tier = tiers[type] ?? BasePadTier.plot;
    final box = layout.slotOf(type).standingBoxOn(tier);
    if (standingHitBox(box).contains(point)) return type;
  }
  return layout.buildingAt(baseProjectionToGround(point));
}
