# Task 11: Add resource amount flash animation

## Summary

Create an `AnimatedResourceAmount` widget that briefly flashes green when a value increases and red when it decreases (~0.5s, color change only). Integrate it into `ResourceBarItem`.

## Implementation Steps

### Step 1: Create `lib/presentation/widgets/animated_resource_amount.dart`

```dart
import 'package:flutter/material.dart';
import '../theme/abyss_colors.dart';

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
  State<AnimatedResourceAmount> createState() => _AnimatedResourceAmountState();
}

class _AnimatedResourceAmountState extends State<AnimatedResourceAmount>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  Color? _flashColor;

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
      _flashColor = widget.amount > oldWidget.amount
          ? AbyssColors.success
          : AbyssColors.error;
      _colorAnimation = ColorTween(
        begin: _flashColor,
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
```

### Step 2: Update `lib/presentation/widgets/resource_bar_item.dart`

Replace the static `Text('${resource.amount}', ...)` with:

```dart
AnimatedResourceAmount(
  amount: resource.amount,
  baseColor: color,
  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
),
```

Import `animated_resource_amount.dart`.

## Dependencies

- Task 05 (ResourceBarItem widget to integrate into).

## Test Plan

- **File:** `test/presentation/widgets/animated_resource_amount_test.dart` (Task 12)
- Test: Displays the amount text.
- Test: Color changes when amount increases (flash green).
- Test: Color changes when amount decreases (flash red).
- Test: Color returns to base after animation completes.

## Notes

- Uses `AnimatedBuilder` (not implicit animation) for precise control over the color tween.
- The flash is color-only — no size or position animation (per US-2).
- Currently, "Next Turn" only increments turn counter, so the flash won't trigger until resource production is implemented. The animation infrastructure is ready.
- File should stay well under 150 lines (~70 lines).
- **Important:** The widget class name in the build method should be `AnimatedBuilder`, which is Flutter's standard animation builder widget.
