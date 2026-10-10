import 'package:flutter/widgets.dart';

import 'guide_halo_painter.dart';

/// Wraps any widget and, while [active], surrounds it with a pulsing cyan
/// glow: what the guide of the tutorial asks to touch. Inactive, it only
/// shows [child] and runs no animation; the glow holds still when the
/// platform asks for fewer animations.
class GuideHalo extends StatefulWidget {
  final bool active;
  final Widget child;

  /// Outline of the glow: a circle, or a rectangle rounded by [radius].
  final BoxShape shape;
  final double radius;

  /// Space between the box of [child] and what the glow surrounds, such
  /// as the margin of a card.
  final EdgeInsets inset;

  const GuideHalo({
    super.key,
    required this.active,
    required this.child,
    this.shape = BoxShape.rectangle,
    this.radius = 12,
    this.inset = EdgeInsets.zero,
  });

  @override
  State<GuideHalo> createState() => _GuideHaloState();
}

class _GuideHaloState extends State<GuideHalo>
    with SingleTickerProviderStateMixin {
  static const _beat = Duration(milliseconds: 900);

  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: _beat, value: 1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(GuideHalo oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  /// Pulses while active and animations are allowed, holds still otherwise.
  void _sync() {
    final bool still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (widget.active && !still) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else if (_pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 1;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  /// The boundary keeps each beat of the glow from repainting anything
  /// but [GuideHalo.child].
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        foregroundPainter:
            widget.active
                ? GuideHaloPainter(
                  pulse: _pulse,
                  shape: widget.shape,
                  radius: widget.radius,
                  inset: widget.inset,
                )
                : null,
        child: widget.child,
      ),
    );
  }
}
