import 'package:flutter/material.dart';

import '../../../domain/objective/objective_completion.dart';
import '../../../domain/objective/temporary/temporary_objective_end.dart';
import '../../../domain/turn/turn_result.dart';
import '../../extensions/objective_extensions.dart';
import '../../extensions/resource_type_extensions.dart';
import '../../extensions/temporary_objective_kind_extensions.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import 'summary_line.dart';

/// Objective lines of the end-of-turn summary: each objective completed
/// with the reward it credited, then each temporary objective ended, done
/// or struck through when missed.
class ObjectiveTurnSection extends StatelessWidget {
  final TurnResult result;

  const ObjectiveTurnSection({super.key, required this.result});

  static bool hasContent(TurnResult result) =>
      result.objectives.isNotEmpty || result.temporaryObjectives.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        for (final completion in result.objectives)
          SummaryLine(
            Icons.flag,
            _completed(context.l10n, completion),
            AbyssColors.success,
          ),
        for (final ended in result.temporaryObjectives)
          ended.isDone
              ? SummaryLine(
                Icons.flag,
                context.l10n.objectiveCompleted(
                  ended.objective.displayTitle(context.l10n),
                ),
                AbyssColors.success,
              )
              : _missed(context.l10n, ended),
      ],
    );
  }

  String _completed(AppLocalizations l10n, ObjectiveCompletion completion) {
    final gains = completion.credited.gainLabel(l10n);
    final title = l10n.objectiveCompleted(
      completion.objective.displayTitle(l10n),
    );
    return gains.isEmpty ? title : '$title ($gains)';
  }

  Widget _missed(AppLocalizations l10n, TemporaryObjectiveEnd ended) =>
      SummaryLine.rich(
        Icons.hourglass_disabled,
        TextSpan(
          children: [
            TextSpan(
              text: ended.objective.displayTitle(l10n),
              style: const TextStyle(decoration: TextDecoration.lineThrough),
            ),
            TextSpan(text: ' ${l10n.objectiveMissed}'),
          ],
        ),
        AbyssColors.warning,
      );
}
