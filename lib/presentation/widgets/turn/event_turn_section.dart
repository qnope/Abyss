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
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        if (predators != null)
          predators.victory
              ? SummaryLine(Icons.shield, l10n.historyPredatorsRepelled,
                  AbyssColors.success)
              : SummaryLine(Icons.dangerous, l10n.turnPredatorsLooted,
                  AbyssColors.error),
        if (defaulted != null)
          SummaryLine(
            Icons.auto_awesome,
            l10n.turnEventDefaulted(defaulted.label(l10n)),
            AbyssColors.warning,
          ),
        if (drawn != null)
          SummaryLine(
            Icons.auto_awesome,
            l10n.turnEventDrawn(drawn.label(l10n)),
            AbyssColors.biolumCyan,
          ),
      ],
    );
  }
}
