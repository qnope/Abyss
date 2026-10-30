import 'dart:ui';

import '../base/base_decor.dart';
import '../base/base_slot_projection.dart';
import '../map/map_projection.dart';
import 'army_layout.dart';

/// A decor of the parade ground: its [kind], the ground [cell] it stands
/// on and how much it is [grown] from the base's size of its kind.
typedef _Placed = (DecorKind kind, Offset cell, double grown);

/// The decor standing between the blocks of the parade ground, as placed
/// on the mockup: corals, sponges and rocks along the rim and the alleys'
/// ends, never on a drill pad nor in the way of the barracks or the depot.
const List<_Placed> _placed = [
  (SeabedDecor.coralTeal, Offset(.4, 3.0), 1.2),
  (SeabedDecor.rock, Offset(3.0, .4), .7),
  (SeabedDecor.spongePurple, Offset(.5, 6.0), 1.0),
  (SeabedDecor.coralPurple, Offset(6.0, .5), 1.1),
  (SeabedDecor.rock, Offset(8.7, 6.1), .6),
  (SeabedDecor.spongeOrange, Offset(6.1, 8.7), .9),
  (SeabedDecor.rock, Offset(.6, 8.6), .7),
  (SeabedDecor.coralPink, Offset(8.6, .6), 1.1),
  (SeabedDecor.rock, Offset(3.1, 6.0), .6),
  (SeabedDecor.coralTeal, Offset(6.0, 3.1), .9),
  (SeabedDecor.coralPink, Offset(8.75, 8.3), 1.0),
];

/// One decor of the parade ground and the [depth] of its foot, as
/// [ArmyLayout.depthOf] gives, to draw it among what stands there.
typedef ArmyDecor = ({MapDecor decor, double depth});

/// The decor of the parade ground, back to front, in projection
/// coordinates, at the base's size (see [baseDecorScale]).
final List<ArmyDecor> armyDecor = [
  for (final (kind, cell, grown) in _placed)
    (
      decor: MapDecor(
        sprite: kind.svgPath,
        foot: baseGroundToProjection(cell),
        size: kind.sizeRatio * baseDecorScale * grown * MapProjection.tileWidth,
      ),
      depth: ArmyLayout.depthOf(cell),
    ),
]..sort((a, b) => a.depth.compareTo(b.depth));
