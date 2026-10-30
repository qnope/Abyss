import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../../domain/building/building_type.dart';
import '../../theme/abyss_colors.dart';
import '../ambience/ambient_motion.dart';
import '../ambience/bubbles_painter.dart';
import '../ambience/rise_glow_painter.dart';
import '../map/map_content_drawer.dart';
import 'base_building_pose.dart';
import 'base_fit.dart';
import 'base_layout.dart';
import 'base_pad_geometry.dart';
import 'base_pad_tier.dart';
import 'base_slot_projection.dart';
import 'base_snapshot.dart';
import 'base_sprite_paints.dart';
import 'base_sprites.dart';

/// Paints the eleven buildings of the base standing on the island, back
/// to front in [BaseLayout.drawOrder], each on its pad: first the soft
/// contact shadow of every built one, then each building's cut-out
/// sprite, a faint cyan ghost while still to build (level 0), or greyed
/// while degraded; last the bubbles rising over the producers.
///
/// The base lives on the shared ambience [clock]: the buildings that
/// work breathe and bubble (see [BaseSnapshot.breathing]); the [rising]
/// ones pop with a glow as [rise] runs, their level just gone up. Only
/// this layer repaints as they move, and not at all while nothing lives.
/// Each building is a single draw of an already rasterized bitmap.
class BaseBuildingsPainter extends CustomPainter {
  final BaseLayout layout;
  final BaseSnapshot snapshot;
  final BaseFit fit;

  /// The bitmaps, nothing drawn while they load.
  final BaseSprites? sprites;

  /// Seconds of the shared ambience clock; nothing moves without it.
  final ValueListenable<double>? clock;

  /// The pop of the [rising] buildings, from 0 to 1.
  final Animation<double>? rise;
  final Set<BuildingType> rising;

  final MapContentDrawer _drawer;
  final Set<BuildingType> _breathing;
  final Map<BuildingType, BubblesPainter> _bubbles;
  final RiseGlowPainter? _glow;
  final _paints = BaseSpritePaints();
  final _shadow = Paint()..filterQuality = FilterQuality.low;

  BaseBuildingsPainter({
    required this.layout,
    required this.snapshot,
    required this.fit,
    this.sprites,
    this.clock,
    this.rise,
    this.rising = const {},
  })  : _drawer = MapContentDrawer(sprites?.map),
        _breathing = clock == null ? const {} : snapshot.breathing,
        _bubbles = {
          if (clock != null)
            for (final type in snapshot.bubbling)
              type: BubblesPainter(clock: clock, seed: type.index, count: 4),
        },
        _glow = rise == null
            ? null
            : RiseGlowPainter(progress: rise, color: AbyssColors.biolumCyan),
        super(repaint: Listenable.merge([
          if (clock != null && snapshot.breathing.isNotEmpty) clock,
          rise,
        ]));

  int _levelOf(BuildingType type) => snapshot.levels[type] ?? 0;

  @override
  void paint(Canvas canvas, Size size) {
    final sprites = this.sprites;
    if (sprites == null) return;
    canvas.save();
    fit.apply(canvas);
    final order = layout.drawOrder;
    for (final type in order) {
      final tier = BasePadTier.ofLevel(_levelOf(type));
      if (tier == BasePadTier.plot) continue;
      final box = layout.slotOf(type).shadowBoxOn(tier);
      _drawer.drawOnFloor(canvas, sprites.map.shadow, box, _shadow);
    }
    final seconds = clock?.value ?? 0;
    for (final type in order) {
      final level = _levelOf(type);
      final box = layout.slotOf(type).standingBoxOn(BasePadTier.ofLevel(level));
      final paint = _paints.of(
          level: level, degraded: snapshot.degraded.contains(type));
      final pose = baseBuildingPose(
        breathing: _breathing.contains(type),
        seconds: seconds,
        phase: AmbientMotion.phaseOf(type.index),
        rise: rising.contains(type) ? rise?.value : null,
      );
      final foot = Rect.fromLTRB(box.left, box.top, box.right,
          box.top + BaseSlotProjection.footRatio * box.height);
      pose.paint(canvas, foot,
          () => _drawer.drawSprite(canvas, sprites.standingOf(type), box, paint));
      if (pose.glow > 0) _paintAt(canvas, box, _glow);
    }
    canvas.restore();
    for (final MapEntry(key: type, value: bubbles) in _bubbles.entries) {
      final tier = BasePadTier.ofLevel(_levelOf(type));
      final area = layout.slotOf(type).bubblesBoxOn(tier);
      _paintAt(canvas, fit.toView(area.topLeft) & area.size * fit.zoom,
          bubbles);
    }
  }

  /// Paints [painter] over [box] of the canvas.
  void _paintAt(Canvas canvas, Rect box, CustomPainter? painter) {
    if (painter == null) return;
    canvas
      ..save()
      ..translate(box.left, box.top);
    painter.paint(canvas, box.size);
    canvas.restore();
  }

  @override
  bool shouldRepaint(BaseBuildingsPainter oldDelegate) =>
      oldDelegate.layout != layout ||
      oldDelegate.fit != fit ||
      oldDelegate.sprites != sprites ||
      oldDelegate.clock != clock ||
      oldDelegate.rise != rise ||
      !setEquals(oldDelegate.rising, rising) ||
      !mapEquals(oldDelegate.snapshot.levels, snapshot.levels) ||
      !setEquals(oldDelegate.snapshot.degraded, snapshot.degraded);

  @override
  bool? hitTest(Offset position) => false;
}
