import 'package:flutter/material.dart';

import '../../../domain/objective/objective_completion.dart';
import '../../../domain/objective/temporary/temporary_objective_end.dart';
import '../../../domain/turn/turn_result.dart';
import '../../extensions/resource_type_extensions.dart';
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

  static const _done = 'Objectif accompli : ';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        for (final completion in result.objectives)
          SummaryLine(Icons.flag, _completed(completion), AbyssColors.success),
        for (final ended in result.temporaryObjectives)
          ended.isDone
              ? SummaryLine(
                Icons.flag,
                '$_done${ended.objective.title}',
                AbyssColors.success,
              )
              : _missed(ended),
      ],
    );
  }

  String _completed(ObjectiveCompletion completion) {
    final gains = completion.credited.gainLabel;
    final title = '$_done${completion.objective.title}';
    return gains.isEmpty ? title : '$title ($gains)';
  }

  Widget _missed(TemporaryObjectiveEnd ended) => SummaryLine.rich(
    Icons.hourglass_disabled,
    TextSpan(
      children: [
        TextSpan(
          text: ended.objective.title,
          style: const TextStyle(decoration: TextDecoration.lineThrough),
        ),
        const TextSpan(text: ' (raté)'),
      ],
    ),
    AbyssColors.warning,
  );
}
