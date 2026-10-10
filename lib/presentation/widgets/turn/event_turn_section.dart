import 'package:flutter/material.dart';

import '../../../domain/turn/turn_result.dart';
import '../../extensions/random_event_type_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import 'summary_line.dart';

/// Event lines of the end-of-turn summary: the predators just fought, the
/// event settled with its prudent option and the event just drawn.
class EventTurnSection extends StatelessWidget {
  final TurnResult result;

  const EventTurnSection({super.key, required this.result});

  static bool hasContent(TurnResult result) =>
      result.predators != null ||
      result.defaultedEvent != null ||
      result.event != null;

  @override
  Widget build(BuildContext context) {
    final predators = result.predators;
    final defaulted = result.defaultedEvent;
    final drawn = result.event;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        if (predators != null)
          predators.victory
              ? const SummaryLine(Icons.shield, 'Banc de prédateurs repoussé',
                  AbyssColors.success)
              : const SummaryLine(Icons.dangerous,
                  'Le banc de prédateurs a pillé la base', AbyssColors.error),
        if (defaulted != null)
          SummaryLine(
            Icons.auto_awesome,
            '${defaulted.label(context.l10n)} : option prudente appliquée',
            AbyssColors.warning,
          ),
        if (drawn != null)
          SummaryLine(
            Icons.auto_awesome,
            'Événement : ${drawn.label(context.l10n)}',
            AbyssColors.biolumCyan,
          ),
      ],
    );
  }
}
