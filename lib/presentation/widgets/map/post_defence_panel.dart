import 'package:flutter/material.dart';

import '../../../domain/faction/post_defence.dart';
import '../../../domain/map/transition_base.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../faction/faction_emblem.dart';

/// The defence of a post the human holds: the largest faction army its
/// scouts reported, if any, then what is lost should [post] fall, and a
/// reminder that the factions strike without warning.
class PostDefencePanel extends StatelessWidget {
  final TransitionBase post;
  final PostDefence defence;

  const PostDefencePanel({
    super.key,
    required this.post,
    required this.defence,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final PostThreat? threat = defence.threat;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (threat != null) ...[
          Row(
            children: [
              FactionEmblem(personality: threat.faction.personality, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.postDefenceThreat(
                    threat.faction.name,
                    threat.units,
                    threat.reportTurn,
                  ),
                  style: textTheme.bodyMedium?.copyWith(
                    color: AbyssColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        Text(
          l10n.postDefenceIfFalls(post.type.name),
          style: textTheme.titleSmall?.copyWith(color: AbyssColors.coralPink),
        ),
        const SizedBox(height: 4),
        _LossLine(l10n.postDefencePassageLost(defence.passage.name)),
        if (defence.unitsBelow > 0)
          _LossLine(
            l10n.postDefenceUnitsLost(defence.unitsBelow, post.targetLevel),
          ),
        if (defence.reinforcements > 0)
          _LossLine(l10n.postDefenceReinforcementsLost(defence.reinforcements)),
        const SizedBox(height: 8),
        Text(
          l10n.postDefenceNoWarning,
          style: textTheme.bodySmall?.copyWith(
            color: AbyssColors.onSurfaceDim,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

/// One thing lost with the post, after a bullet.
class _LossLine extends StatelessWidget {
  final String text;

  const _LossLine(this.text);

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: style?.copyWith(color: AbyssColors.coralPink)),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }
}
