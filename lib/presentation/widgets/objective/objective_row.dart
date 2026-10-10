import 'package:flutter/material.dart';

import '../../../domain/objective/objective_progress.dart';
import '../../../domain/resource/resource_type.dart';
import '../../theme/abyss_colors.dart';
import '../resource/resource_gains_row.dart';

/// Where an objective stands in the list of objectives.
enum ObjectiveStatus {
  done(Icons.check_circle, AbyssColors.onSurfaceDim, AbyssColors.success),
  current(Icons.flag, AbyssColors.biolumCyan, AbyssColors.biolumCyan),
  toDo(
    Icons.radio_button_unchecked,
    AbyssColors.onSurface,
    AbyssColors.onSurfaceDim,
  ),

  /// Set by an event for a while.
  temporary(Icons.hourglass_bottom, AbyssColors.warning, AbyssColors.warning);

  final IconData icon;
  final Color textColor;
  final Color iconColor;

  const ObjectiveStatus(this.icon, this.textColor, this.iconColor);
}

/// One objective of the list: its status, its title, its progress when it
/// is the current one, and its reward.
class ObjectiveRow extends StatelessWidget {
  final String title;
  final ObjectiveStatus status;

  /// Shown at the end of the row, for the current objective.
  final ObjectiveProgress? progress;

  final Map<ResourceType, int> reward;

  const ObjectiveRow({
    super.key,
    required this.title,
    required this.status,
    this.progress,
    this.reward = const {},
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: status.textColor);
    final progress = this.progress;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(status.icon, size: 18, color: status.iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: style),
                if (reward.isNotEmpty) ResourceGainsRow(gains: reward),
              ],
            ),
          ),
          if (progress != null) ...[
            const SizedBox(width: 8),
            Text('$progress', style: style),
          ],
        ],
      ),
    );
  }
}
