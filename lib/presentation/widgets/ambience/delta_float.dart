import 'package:flutter/widgets.dart';

import '../../theme/abyss_colors.dart';
import '../../theme/abyss_motion.dart';

/// Shows [child] and, each time [value] changes, floats the difference
/// ("+N" in [gainColor], "−N" in [lossColor]) up from it while it fades.
///
/// Nothing floats when first shown; a new change replaces the float
/// under way. The last value seen is kept, so a value mutated in place
/// still floats. When the platform reduces motion, nothing floats.
/// The float never changes the size of [child].
class DeltaFloat extends StatefulWidget {
  final int value;
  final Widget child;
  final TextStyle style;
  final Color gainColor;
  final Color lossColor;

  /// How far the float rises, in logical pixels.
  final double rise;

  const DeltaFloat({
    super.key,
    required this.value,
    required this.child,
    this.style = defaultStyle,
    this.gainColor = AbyssColors.success,
    this.lossColor = AbyssColors.error,
    this.rise = defaultRise,
  });

  /// The look of a float, unless told otherwise, and how far it rises.
  static const defaultStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );
  static const double defaultRise = 22;

  /// Share of its rise a float has gone up at [t], from 0 to 1.
  static double liftAt(double t) => AbyssMotion.enter.transform(t);

  /// Opacity of a float at [t], from 0 to 1.
  static double fadeAt(double t) => 1 - AbyssMotion.exit.transform(t);

  /// "+N" for a gain, "−N" (with a true minus sign) for a loss.
  static String label(int delta) =>
      delta >= 0 ? '+$delta' : '−${-delta}';

  @override
  State<DeltaFloat> createState() => _DeltaFloatState();
}

class _DeltaFloatState extends State<DeltaFloat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: AbyssMotion.deltaFloat,
  )..addStatusListener((_) => setState(() {}));
  late int _shown;
  int _delta = 0;

  @override
  void initState() {
    super.initState();
    _shown = widget.value;
  }

  @override
  void didUpdateWidget(DeltaFloat oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _shown) _start(widget.value - _shown);
    _shown = widget.value;
  }

  void _start(int delta) {
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduced) return _float.reset();
    _delta = delta;
    _float.forward(from: 0);
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      widget.child,
      if (_float.isAnimating)
        Positioned.fill(
          child: IgnorePointer(
            child: OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              alignment: Alignment.topCenter,
              child: AnimatedBuilder(animation: _float, builder: _floating),
            ),
          ),
        ),
    ],
  );

  Widget _floating(BuildContext context, Widget? _) {
    final t = _float.value;
    final color = _delta >= 0 ? widget.gainColor : widget.lossColor;
    final fade = DeltaFloat.fadeAt(t);
    return Transform.translate(
      offset: Offset(0, -widget.rise * DeltaFloat.liftAt(t)),
      child: Text(
        DeltaFloat.label(_delta),
        softWrap: false,
        style: widget.style.copyWith(
          color: color.withValues(alpha: color.a * fade),
        ),
      ),
    );
  }
}
