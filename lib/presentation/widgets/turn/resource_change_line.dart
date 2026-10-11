import 'package:flutter/material.dart';
import '../../../domain/turn/turn_result.dart';
import '../../extensions/resource_type_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../resource/resource_icon.dart';

/// One resource of the end-of-turn summary: what was produced and consumed.
class ResourceChangeLine extends StatelessWidget {
  final TurnResourceChange change;

  const ResourceChangeLine({super.key, required this.change});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          ResourceIcon(type: change.type),
          const SizedBox(width: 8),
          Text(change.type.displayName(l10n)),
          const Spacer(),
          Text(_format(), style: TextStyle(color: change.type.color)),
          if (change.wasCapped) ...[
            const SizedBox(width: 4),
            Text(
              l10n.turnStorageFull,
              style: TextStyle(color: AbyssColors.warning),
            ),
          ],
        ],
      ),
    );
  }

  String _format() => change.consumed > 0
      ? '+${change.produced}/-${change.consumed}'
      : '+${change.produced}';
}
