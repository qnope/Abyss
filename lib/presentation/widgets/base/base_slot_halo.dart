import 'package:flutter/widgets.dart';

import '../../theme/abyss_base_badge_theme.dart';
import '../guide/guide_halo.dart';
import 'base_badge_geometry.dart';
import 'base_drawing.dart';
import 'base_fit.dart';
import 'base_slot.dart';

/// The guide's ring around [slot], laid on the ground of an island seen
/// through [fit]: a pulsing diamond just outside its footprint, a light
/// on each of its four tips, keyed [ringKey]. Shows nothing without a
/// slot. Laid in a Stack over the island, as BaseGuideHalo on the base
/// and ArmyGuideHalo on the parade ground do.
class BaseSlotHalo extends StatelessWidget {
  final BaseSlot? slot;
  final BaseFit fit;
  final Key? ringKey;

  /// Radius of a tip's light, in projection units.
  static const dotRadius = 3 * baseMockPixel;

  const BaseSlotHalo({
    super.key,
    required this.slot,
    required this.fit,
    this.ringKey,
  });

  @override
  Widget build(BuildContext context) {
    final box = slot?.ringBox;
    if (box == null) {
      return const Positioned(left: 0, top: 0, child: SizedBox.shrink());
    }
    return Positioned.fromRect(
      rect: Rect.fromPoints(
        fit.toView(box.topLeft),
        fit.toView(box.bottomRight),
      ),
      child: IgnorePointer(
        child: GuideHalo(
          active: true,
          outline: diamondOf,
          child: CustomPaint(
            key: ringKey,
            painter: _TipLights(dotRadius * fit.zoom),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }

  /// The diamond drawn in [box].
  static Path diamondOf(Rect box) => polygonOf(diamondCorners(box));
}

/// The four lights on the tips of the ring's diamond.
class _TipLights extends CustomPainter {
  final double radius;

  _TipLights(this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AbyssBaseBadgeTheme.ringDot;
    for (final tip in diamondCorners(Offset.zero & size)) {
      canvas.drawCircle(tip, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_TipLights oldDelegate) => oldDelegate.radius != radius;
}
