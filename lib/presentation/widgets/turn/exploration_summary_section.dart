import 'package:flutter/material.dart';

import '../../../domain/map/exploration_result.dart';
import '../../extensions/cell_content_type_extensions.dart';
import '../../theme/abyss_colors.dart';

class ExplorationSummarySection extends StatelessWidget {
  final List<ExplorationResult> explorations;

  const ExplorationSummarySection({super.key, required this.explorations});

  @override
  Widget build(BuildContext context) {
    final totalNew = explorations.fold<int>(
      0,
      (sum, e) => sum + e.newCellsRevealed,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Row(
          children: [
            Icon(Icons.explore, color: AbyssColors.biolumCyan),
            const SizedBox(width: 8),
            Text(
              'Exploration : $totalNew nouvelles cellules',
              style: TextStyle(color: AbyssColors.biolumCyan),
            ),
          ],
        ),
        for (final exploration in explorations)
          Padding(
            padding: const EdgeInsets.only(left: 28, top: 4),
            child: Text(
              _formatExploration(exploration),
              style: TextStyle(
                color: AbyssColors.biolumCyan.withValues(alpha: 0.7),
              ),
            ),
          ),
      ],
    );
  }

  String _formatExploration(ExplorationResult exploration) {
    final coords = '(${exploration.target.x}, ${exploration.target.y})';
    final cells = '${exploration.newCellsRevealed} cellules';
    if (exploration.notableContent.isEmpty) {
      return '$coords → $cells';
    }
    final notable = exploration.notableContent.map((c) => c.label).join(', ');
    return '$coords → $cells ($notable)';
  }
}
