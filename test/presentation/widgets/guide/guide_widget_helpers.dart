import 'package:abyss/domain/objective/guide/guide_target.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/guide/guide_halo.dart';
import 'package:abyss/presentation/widgets/guide/guide_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every halo shown.
final Finder activeHalos = find.byWidgetPredicate(
  (widget) => widget is GuideHalo && widget.active,
);

/// The halos shown around [child].
Finder haloAround(Finder child) =>
    find.ancestor(of: child, matching: activeHalos);

/// [child] in the themed app, the guide pointing at [target].
Widget guidedApp(Widget child, GuideTarget? target) => MaterialApp(
  theme: AbyssTheme.create(),
  home: GuideScope(target: target, child: Scaffold(body: child)),
);
