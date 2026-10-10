import 'package:flutter/material.dart';

import '../../../domain/game/game.dart';
import '../../../domain/game/player.dart';
import '../../../domain/objective/current_objective.dart';
import '../../../domain/objective/temporary/temporary_objectives.dart';
import '../../extensions/objective_extensions.dart';
import '../../extensions/temporary_objective_kind_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';

/// Thin strip under the status bars: the objective the player is on, its
/// chapter and its progress, and the temporary objectives of the events.
/// Hidden once every objective is completed.
class ObjectiveBanner extends StatelessWidget {
  final Game game;
  final Player player;

  /// Opens the sheet of every objective.
  final VoidCallback? onTap;

  const ObjectiveBanner({
    super.key,
    required this.game,
    required this.player,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final objective = CurrentObjective.of(game, player);
    if (objective == null) return const SizedBox.shrink();
    final progress = objective.progressOf(game, player);
    final temporary = TemporaryObjectives.activeOf(game, player);
    final l10n = context.l10n;
    final style = Theme.of(context).textTheme.bodySmall;
    final color =
        progress.isDone ? AbyssColors.success : AbyssColors.biolumCyan;
    return Material(
      color: AbyssColors.surfaceDim,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
          child: Row(
            children: [
              Icon(Icons.flag, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                objective.chapter.title(l10n),
                style: style?.copyWith(color: AbyssColors.onSurfaceDim),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.objectiveProgress(
                    objective.displayTitle(l10n),
                    progress.current,
                    progress.target,
                  ),
                  style: style?.copyWith(color: color),
                ),
              ),
              if (temporary.isNotEmpty)
                Text(
                  '+ ${temporary.map((t) => t.kind.shortLabel(l10n)).join(', ')}',
                  style: style?.copyWith(color: AbyssColors.warning),
                ),
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: AbyssColors.onSurfaceDim,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
