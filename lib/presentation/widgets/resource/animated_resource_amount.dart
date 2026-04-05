import 'package:flutter/material.dart';
import '../../theme/abyss_colors.dart';

class AnimatedResourceAmount extends StatefulWidget {
  final int amount;
  final Color baseColor;
  final TextStyle? style;

  const AnimatedResourceAmount({
    super.key,
    required this.amount,
    required this.baseColor,
    this.style,
  });

  @override
  State<AnimatedResourceAmount> createState() =>
      _AnimatedResourceAmountState();
}

class _AnimatedResourceAmountState extends State<AnimatedResourceAmount>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: widget.baseColor,
      end: widget.baseColor,
    ).animate(_controller);
  }

  @override
  void didUpdateWidget(AnimatedResourceAmount oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      final flashColor = widget.amount > oldWidget.amount
          ? AbyssColors.success
          : AbyssColors.error;
      _colorAnimation = ColorTween(
        begin: flashColor,
        end: widget.baseColor,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Text(
          '${widget.amount}',
          style: (widget.style ?? const TextStyle()).copyWith(
            color: _colorAnimation.value,
          ),
        );
      },
    );
  }
}
