import 'package:flutter/material.dart';

import '../../theme/abyss_colors.dart';

enum _SaveAction { delete }

/// The « ⋮ » options of a save card. Its tap stays its own: it never
/// opens the game the card stands for.
class SaveCardMenu extends StatelessWidget {
  final VoidCallback onDelete;

  const SaveCardMenu({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: AbyssColors.error);
    return PopupMenuButton<_SaveAction>(
      tooltip: 'Options',
      icon: const Icon(Icons.more_vert, size: 20),
      iconColor: AbyssColors.onSurfaceDim,
      onSelected: (_) => onDelete(),
      itemBuilder:
          (_) => [
            PopupMenuItem(
              value: _SaveAction.delete,
              child: Row(
                children: [
                  const Icon(Icons.delete_outline, color: AbyssColors.error),
                  const SizedBox(width: 12),
                  Text('Supprimer', style: style),
                ],
              ),
            ),
          ],
    );
  }
}
