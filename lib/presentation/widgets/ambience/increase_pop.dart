import 'package:flutter/widgets.dart';

import '../../theme/abyss_motion.dart';
import 'pose_box.dart';
import 'rise_glow_painter.dart';
import 'rise_motion.dart';

/// Makes [child], a box of [size], rise once (see [RiseMotion]) each time
/// [value] goes up, e.g. a level or a count, with a glow of [glowColor].
///
/// Nothing moves when first shown nor when [value] stays or goes down;
/// the last value seen is kept, so a value mutated in place still pops.
/// When the platform reduces motion, the final state shows at once.
class IncreasePop extends StatefulWidget {
  final int value;
  final Size size;
  final Color glowColor;
  final Widget child;

  const IncreasePop({
    super.key,
    required this.value,
    required this.size,
    required this.glowColor,
    required this.child,
  });

  @override
  State<IncreasePop> createState() => _IncreasePopState();
}

class _IncreasePopState extends State<IncreasePop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rise = AnimationController(
    vsync: this,
    duration: AbyssMotion.emphasis,
    value: 1,
  );
  late int _shown;

  @override
  void initState() {
    super.initState();
    _shown = widget.value;
  }

  @override
  void didUpdateWidget(IncreasePop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value > _shown) _pop();
    _shown = widget.value;
  }

  void _pop() {
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    reduced ? _rise.value = 1 : _rise.forward(from: 0);
  }

  @override
  void dispose() {
    _rise.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: Stack(
      alignment: Alignment.topLeft,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: RiseGlowPainter(
                progress: _rise,
                color: widget.glowColor,
              ),
            ),
          ),
        ),
        PoseBox(
          size: widget.size,
          repaint: _rise,
          pose: () => RiseMotion.at(_rise.value),
          child: widget.child,
        ),
      ],
    ),
  );
}
