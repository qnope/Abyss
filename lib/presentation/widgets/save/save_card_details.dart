import 'package:flutter/material.dart';

import '../../../domain/game/save_summary.dart';
import '../../extensions/relative_date_extensions.dart';
import '../../extensions/save_summary_extensions.dart';
import '../../theme/abyss_colors.dart';
import '../common/status_pill.dart';
import '../resource/resource_amount_strip.dart';

/// The text of a save card: name and badge, last played date, turn and
/// depth, then the resources of a game in progress or how it ended.
class SaveCardDetails extends StatelessWidget {
  final SaveSummary summary;
  final DateTime now;

  /// Mutes every color, for a lost game.
  final bool faded;

  /// Room kept free at the end of the lower lines, under the options.
  static const double trailingGap = 28;

  const SaveCardDetails({
    super.key,
    required this.summary,
    required this.now,
    this.faded = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final footnote = summary.footnote;
    final dim = AbyssColors.onSurfaceDim;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _title(text)),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                summary.lastPlayedAt.relativeTo(now),
                style: text.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(right: trailingGap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                summary.metaLine,
                style: text.bodyMedium?.copyWith(
                  color: faded ? dim : AbyssColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              if (footnote == null)
                ResourceAmountStrip(amounts: summary.resources)
              else
                Text(
                  footnote,
                  style: text.bodySmall?.copyWith(
                    color: faded ? AbyssColors.dimmed(dim) : dim,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// The name keeps its line, ellipsized; the badge follows it, or moves
  /// under it when the name is too long.
  Widget _title(TextTheme text) => Wrap(
    spacing: 8,
    runSpacing: 2,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text(
        summary.playerName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: text.headlineLarge?.copyWith(
          height: 1.1,
          color: faded ? AbyssColors.onSurfaceDim : AbyssColors.biolumCyan,
        ),
      ),
      StatusPill(
        label: summary.badgeLabel,
        color: summary.badgeColor,
        faded: faded,
      ),
    ],
  );
}
