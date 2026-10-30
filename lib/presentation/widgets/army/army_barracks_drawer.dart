import 'package:flutter/painting.dart';

import '../../../domain/building/building_type.dart';
import '../../extensions/building_type_extensions.dart';
import '../base/base_badge_geometry.dart';
import '../base/base_drawing.dart';
import '../base/base_pad_drawer.dart';
import '../base/base_pad_geometry.dart';
import '../base/base_pad_tier.dart';
import '../base/base_plaque_drawer.dart';
import '../base/base_sprite_paints.dart';
import '../base/base_sprites.dart';
import '../map/map_content_drawer.dart';
import 'army_slots.dart';

const _type = BuildingType.barracks;

/// Draws, in projection coordinates, the barracks at the back of the
/// parade ground as the base draws it (see [ArmySlots.barracks]): its pad
/// at its tier, the building standing on it (a faint ghost on a plot
/// while still to build, greyed while degraded), and its level's plaque
/// with its name, or the « À bâtir » pill of its plot.
class ArmyBarracksDrawer {
  static const _plaques = BasePlaqueDrawer();

  final _pads = BasePadDrawer();
  final _paints = BaseSpritePaints();
  final _shadow = Paint()..filterQuality = FilterQuality.low;

  /// Draws the pad of the barracks at [level].
  void paintPad(Canvas canvas, int level) => _pads.paint(canvas,
      ArmySlots.barracks, BasePadTier.ofLevel(level), _type.color,
      seed: _type.index);

  /// Draws the barracks at [level] standing on its pad, from [sprites].
  void paintStanding(Canvas canvas, BaseSprites sprites,
      {required int level, required bool degraded}) {
    final slot = ArmySlots.barracks, tier = BasePadTier.ofLevel(level);
    if (tier != BasePadTier.plot) {
      MapContentDrawer(sprites.map).drawOnFloor(
          canvas, sprites.map.shadow, slot.shadowBoxOn(tier), _shadow);
    }
    drawWholeImage(canvas, sprites.standingOf(_type), slot.standingBoxOn(tier),
        _paints.of(level: level, degraded: degraded));
  }

  /// Draws the plaque of the barracks at [level] and its [name] under it;
  /// on its plot, the pill saying [toBuild], [locked] while a
  /// prerequisite is missing.
  void paintPlaque(Canvas canvas,
      {required int level,
      required String name,
      required String toBuild,
      required bool locked}) {
    final at = ArmySlots.barracks.plaqueAt(level);
    if (level > 0) {
      _plaques.level(canvas, at, level, _type.color);
    } else {
      _plaques.toBuild(canvas, at, toBuild, locked: locked);
    }
    _plaques.name(canvas, at, name);
  }
}
