import 'package:flutter/material.dart';
import '../../../domain/tech/tech_branch.dart';
import '../../../domain/tech/tech_tree.dart';
import '../../extensions/tech_branch_extensions.dart';
import '../../extensions/tech_node_extensions.dart';
import '../../theme/abyss_colors.dart';
import '../common/raster_svg.dart';

/// Top of the reef popup: the icon, name and effect of a branch or a
/// tier node, with its action button. A choice node only gets a title,
/// its options carry their own buttons.
class TechTargetHeader extends StatelessWidget {
  final TechBranch branch;
  final int? level;
  final bool canAct;
  final VoidCallback? onAct;

  const TechTargetHeader({
    super.key,
    required this.branch,
    required this.level,
    required this.canAct,
    this.onAct,
  });

  bool get _choice => level != null && TechTree.isChoiceLevel(level!);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(children: [
      if (!_choice) ...[
        RasterSvg(assetPath: _iconPath, size: 48),
        const SizedBox(width: 12),
      ],
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_title,
              style: text.titleMedium?.copyWith(
                color: branch.color, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(_subtitle,
              style: text.bodySmall?.copyWith(
                color: AbyssColors.onSurfaceDim)),
          ],
        ),
      ),
      if (onAct != null) ...[
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: canAct ? onAct : null,
          child: Text(level == null ? 'Débloquer' : 'Rechercher'),
        ),
      ],
    ]);
  }

  String get _iconPath =>
      level == null ? branch.iconPath : branch.nodeIconPath(level!);

  String get _title => switch (level) {
    null => branch.displayName,
    final l when _choice => '${branch.displayName} · Niveau $l · Choix',
    final l => branch.nodeName(l),
  };

  String get _subtitle => switch (level) {
    null => branch.description,
    _ when _choice => "Une seule option par partie, l'autre sera perdue.",
    final l => '${branch.displayName} · Niveau $l · ${branch.nodeEffect(l)}',
  };
}
