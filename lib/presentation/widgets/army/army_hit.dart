import 'dart:ui';

import '../base/base_pad_geometry.dart';
import '../base/base_pad_tier.dart';
import '../base/base_slot_projection.dart';
import '../map/map_standing_hit.dart';
import 'army_draw_order.dart';
import 'army_layout.dart';
import 'army_piece.dart';
import 'army_roster.dart';
import 'army_slots.dart';
import 'army_squad_geometry.dart';

/// The piece of the parade ground of [roster] under the projection
/// [point], as the base picks its buildings (see baseBuildingAt): the
/// front-most one standing there in [ArmyDrawOrder] (a figure of a squad,
/// its banner or the barracks), as a piece overlaps the ground behind its
/// own; else the squad whose drill pad, or the barracks whose footprint,
/// lies there; `null` elsewhere. The depot picks nothing.
ArmyPiece? armyPieceAt(Offset point, ArmyRoster roster) {
  final pieces = ArmyDrawOrder.backToFront;
  for (var k = pieces.length - 1; k >= 0; k--) {
    final piece = pieces[k];
    if (_standsOver(piece, point, roster)) return piece;
  }
  final ground = baseProjectionToGround(point);
  final type = ArmyLayout.unitAt(ground);
  if (type != null) return SquadPiece(type);
  if (ArmySlots.barracks.contains(ground)) return const BarracksPiece();
  return null;
}

/// Whether [piece] stands over the projection [point].
bool _standsOver(
  ArmyPiece piece,
  Offset point,
  ArmyRoster roster,
) => switch (piece) {
  BarracksPiece() => standingHitBox(
    ArmySlots.barracks.standingBoxOn(BasePadTier.ofLevel(roster.barracksLevel)),
  ).contains(point),
  DepotPiece() => false,
  BannerPiece(:final type) => ArmySquadGeometry.bannerBox(
    ArmySquadGeometry.bannerFoot(type, locked: roster.isLocked(type)),
  ).contains(point),
  SquadPiece(:final type) => ArmySquadGeometry.feetOf(
    type,
    roster.figuresOf(type),
    locked: roster.isLocked(type),
  ).any(
    (feet) => standingHitBox(ArmySquadGeometry.figureBox(feet)).contains(point),
  ),
};
