import 'package:flutter/widgets.dart';

import '../../../theme/abyss_trench_theme.dart';
import '../../common/raster_paint.dart';

/// The haze of depth over a deep-sea scene, in screen space: bluish
/// toward the top of its box (where the eye looks far), clear in the
/// middle, darker at the bottom (see [AbyssTrenchTheme.haze]).
///
/// Fills its box. Lay it over a pannable content, outside its
/// InteractiveViewer: it stays still, is painted once in its own repaint
/// boundary and never takes a tap. A gradient over the whole screen is
/// costly to shade again at every frame where pictures are not
/// raster-cached (the web, Impeller): it is drawn from a small bitmap
/// of it ([resolution]), stretched, as smooth.
class DepthHaze extends StatelessWidget {
  /// Pixels per logical pixel of the haze's bitmap: a few dozen rows
  /// hold its gentle gradient.
  static const resolution = 1 / 8;

  const DepthHaze({super.key});

  @override
  Widget build(BuildContext context) => const IgnorePointer(
        child: RepaintBoundary(
          child: RasterPaint(painter: _HazePainter(), resolution: resolution),
        ),
      );
}

/// Paints [AbyssTrenchTheme.haze] over its box.
class _HazePainter extends CustomPainter {
  const _HazePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final box = Offset.zero & size;
    canvas.drawRect(
        box, Paint()..shader = AbyssTrenchTheme.haze.createShader(box));
  }

  @override
  bool shouldRepaint(_HazePainter oldDelegate) => false;
}
