import 'package:flutter/widgets.dart';

import '../../../domain/building/building_type.dart';
import '../../theme/abyss_base_badge_theme.dart';
import '../guide/guide_halo.dart';
import '../guide/guide_scope.dart';
import 'base_badge_geometry.dart';
import 'base_drawing.dart';
import 'base_fit.dart';
import 'base_layout.dart';

/// The guide's ring around the slot of the building it points at, laid
/// on the ground of the base seen through [fit]: a pulsing diamond just
/// outside its footprint, a light on each of its four tips. Shows
/// nothing when the guide points at no building.
class BaseGuideHalo extends StatelessWidget {
  final BaseLayout layout;
  final BaseFit fit;

  /// Radius of a tip's light, in projection units.
  static const dotRadius = 3 * baseMockPixel;

  const BaseGuideHalo({super.key, required this.layout, required this.fit});

  /// The key of what the ring surrounds on the slot of [type].
  static Key keyOf(BuildingType type) => ValueKey(('base guide', type));

  @override
  Widget build(BuildContext context) {
    final type = GuideScope.of(context)?.building;
    if (type == null || !layout.slots.containsKey(type)) {
      return const Positioned(left: 0, top: 0, child: SizedBox.shrink());
    }
    final box = layout.slotOf(type).ringBox;
    return Positioned.fromRect(
      rect: Rect.fromPoints(
          fit.toView(box.topLeft), fit.toView(box.bottomRight)),
      child: IgnorePointer(
        child: GuideHalo(
          active: true,
          outline: diamondOf,
          child: CustomPaint(
            key: keyOf(type),
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
