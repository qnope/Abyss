import 'package:flutter/material.dart';

import 'guide_halo.dart';

/// A [GuideHalo] fitted to a themed [Card]: it skips the card's margin and
/// follows its rounded corners.
class GuideCardHalo extends StatelessWidget {
  final bool active;
  final Widget child;

  const GuideCardHalo({super.key, required this.active, required this.child});

  @override
  Widget build(BuildContext context) {
    final card = Theme.of(context).cardTheme;
    final shape = card.shape;
    final radius =
        shape is RoundedRectangleBorder
            ? shape.borderRadius.resolve(Directionality.of(context)).topLeft.x
            : 12.0;
    return GuideHalo(
      active: active,
      inset:
          card.margin?.resolve(Directionality.of(context)) ??
          const EdgeInsets.all(4),
      radius: radius,
      child: child,
    );
  }
}
