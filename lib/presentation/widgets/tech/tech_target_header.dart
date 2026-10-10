import 'package:flutter/material.dart';
import '../../../domain/tech/tech_branch.dart';
import '../../../domain/tech/tech_tree.dart';
import '../../extensions/tech_branch_extensions.dart';
import '../../extensions/tech_node_extensions.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_extension.dart';
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
    final l10n = context.l10n;
    return Row(children: [
      if (!_choice) ...[
        RasterSvg(assetPath: _iconPath, size: 48),
        const SizedBox(width: 12),
      ],
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_title(l10n),
              style: text.titleMedium?.copyWith(
                color: branch.color, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(_subtitle(l10n),
              style: text.bodySmall?.copyWith(
                color: AbyssColors.onSurfaceDim)),
          ],
        ),
      ),
      if (onAct != null) ...[
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: canAct ? onAct : null,
          child: Text(level == null
              ? l10n.techScreenUnlock
              : l10n.techScreenResearch),
        ),
      ],
    ]);
  }

  String get _iconPath =>
      level == null ? branch.iconPath : branch.nodeIconPath(level!);

  String _title(AppLocalizations l10n) => switch (level) {
    null => branch.displayName(l10n),
    final l when _choice =>
      l10n.techScreenChoiceTitle(branch.displayName(l10n), l),
    final l => branch.nodeName(l10n, l),
  };

  String _subtitle(AppLocalizations l10n) => switch (level) {
    null => branch.description(l10n),
    _ when _choice => l10n.techScreenChoiceWarning,
    final l => l10n.techScreenNodeSubtitle(
      branch.displayName(l10n), l, branch.nodeEffect(l10n, l)),
  };
}
