import 'package:flutter/widgets.dart';

import '../../extensions/building_type_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../guide/guide_scope.dart';
import 'base_badges_painter.dart';
import 'base_fit.dart';
import 'base_layout.dart';
import 'base_snapshot.dart';

/// The marks over the buildings of the base seen through [fit], in their
/// own layer: plaques, pills, chevrons and triangles, and the name of the
/// plot the guide points at.
class BaseBadgesLayer extends StatelessWidget {
  final BaseLayout layout;
  final BaseFit fit;
  final BaseSnapshot snapshot;

  const BaseBadgesLayer({
    super.key,
    required this.layout,
    required this.fit,
    required this.snapshot,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final guided = GuideScope.of(context)?.building;
    return RepaintBoundary(
      child: CustomPaint(
        painter: BaseBadgesPainter(
          layout: layout,
          fit: fit,
          snapshot: snapshot,
          toBuild: l10n.baseToBuild,
          guided: guided,
          guidedName: guided?.displayName(l10n),
        ),
      ),
    );
  }
}
