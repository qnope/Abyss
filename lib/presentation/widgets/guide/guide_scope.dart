import 'package:flutter/widgets.dart';

import '../../../domain/objective/guide/guide_target.dart';

/// Hands the target of the guide's halo down to the widgets that may
/// carry it: tabs, cards, research medallions and nodes, « Tour suivant ».
class GuideScope extends InheritedWidget {
  /// What the halo surrounds, `null` when the guide is silent.
  final GuideTarget? target;

  const GuideScope({super.key, required this.target, required super.child});

  /// The target of the nearest scope, `null` without one.
  static GuideTarget? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GuideScope>()?.target;

  /// Whether the halo surrounds what [picks] recognizes in the target.
  static bool points(
    BuildContext context,
    bool Function(GuideTarget target) picks,
  ) {
    final GuideTarget? target = of(context);
    return target != null && picks(target);
  }

  @override
  bool updateShouldNotify(GuideScope oldWidget) => oldWidget.target != target;
}
