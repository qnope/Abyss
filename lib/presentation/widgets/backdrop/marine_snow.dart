import 'package:flutter/widgets.dart';

import 'marine_snow_field.dart';
import 'marine_snow_painter.dart';

/// Marine snow rising through the whole box, with breathing light rays.
///
/// One controller drives a single painter inside its own repaint
/// boundary: only this layer is redrawn each frame. The flakes stand
/// still when [animate] is false or the system asks to reduce motion, and
/// the ticker pauses while a route covers the screen (TickerMode).
class MarineSnow extends StatefulWidget {
  final bool animate;

  /// Duration of one seamless cycle: the slowest flakes cross the box
  /// once in it.
  static const cycle = Duration(seconds: 60);

  const MarineSnow({super.key, this.animate = true});

  @override
  State<MarineSnow> createState() => _MarineSnowState();
}

class _MarineSnowState extends State<MarineSnow>
    with SingleTickerProviderStateMixin {
  static final _field = MarineSnowField();

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: MarineSnow.cycle,
  );
  late final MarineSnowPainter _painter = MarineSnowPainter(
    animation: _controller,
    field: _field,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(MarineSnow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final moving = widget.animate && !reduced;
    if (moving && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!moving && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(painter: _painter, size: Size.infinite),
    );
  }
}
