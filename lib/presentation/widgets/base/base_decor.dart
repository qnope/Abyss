import 'dart:ui';

import '../map/decor/decor_scatter.dart';
import 'base_layout.dart';
import 'base_pad_geometry.dart';
import 'base_pad_tier.dart';
import 'base_rampart.dart';
import 'base_slot.dart';
import 'base_slot_projection.dart';
import 'base_walkway_drawer.dart';
import 'base_walkways.dart';

export '../map/decor/decor_scatter.dart';

/// The salt of the base's decor, so it never changes from a game to the
/// next.
const baseDecorSalt = 44;

/// Size of the base's decor against the map's: seen from nearer, among
/// buildings two cells wide, it stays a detail between them.
const baseDecorScale = 0.6;

/// The map's kinds of decor, at the base's size.
final List<DecorKind> baseDecorKinds = [
  for (final kind in SeabedDecor.all)
    DecorKind(kind.svgPath,
        weight: kind.weight, sizeRatio: kind.sizeRatio * baseDecorScale),
];

/// Share of a sprite's side its breathing or its pop may grow it by.
const _motionMargin = 0.05;

/// Everything the building of [slot] may draw over the ground, whatever
/// its level: its sprite on its highest pad as it breathes or pops, and
/// its shadow.
Rect baseStandingReach(BaseSlot slot) {
  final box = slot.standingBox
      .expandToInclude(slot.standingBoxOn(BasePadTier.litDeck));
  return box
      .inflate(_motionMargin * box.width)
      .expandToInclude(slot.shadowBox);
}

/// The decor standing between the slots of [layout], back to front, in
/// projection coordinates (see [scatterDecor]), the same for a [salt].
///
/// None stands on a footprint, on a walkway (all of them, so that what
/// is built changes nothing) nor on the rim where the rampart rises;
/// none hides a pad, nor stands before a building over what it may draw
/// ([baseStandingReach]): all of it can lie in the still island, under
/// the buildings, which hide the decor behind them.
List<MapDecor> baseDecorOf(BaseLayout layout, {int salt = baseDecorSalt}) {
  final n = layout.size;
  final clear = [
    for (final slot in layout.slots.values) slot.bounds.inflate(_footprintGap),
    for (final (from, to) in baseWalkways(layout, layout.slots.keys))
      Rect.fromPoints(from, to)
          .inflate(BaseWalkwayDrawer.standardWidth / 2 + _walkwayGap),
  ];
  final decor = scatterDecor(
    columns: n,
    rows: n,
    salt: salt,
    kinds: baseDecorKinds,
    keepOut: [
      for (final slot in layout.slots.values)
        DecorKeepOut(
          core: slot.footprintBox.expandToInclude(slot.footprintBox
              .shift(Offset(0, -BasePadTier.litDeck.lift))),
          drawn: baseStandingReach(slot),
          depth: slot.foot.dy,
        ),
    ],
  );
  final inner = layout.ground.deflate(_rim);
  bool free(Offset ground) =>
      inner.contains(ground) && !clear.any((area) => area.contains(ground));
  return [
    for (final item in decor)
      if (free(baseProjectionToGround(item.foot))) item,
  ];
}

/// How far from a footprint and from a walkway's sides a decor keeps its
/// foot, in cells.
const _footprintGap = 0.2;
const _walkwayGap = 0.15;

/// The band along the plateau's edges kept free, in cells: the rampart's
/// and a little more.
const _rim = BaseRampart.inset + BaseRampart.thickness + 0.1;
