import 'package:flutter/material.dart';

import '../../../domain/game/game.dart';
import '../../../domain/game/player.dart';
import '../../../domain/objective/current_objective.dart';
import '../../../domain/objective/objective.dart';
import '../../../domain/objective/objective_catalog.dart';
import '../../../domain/objective/objective_chapter.dart';
import '../../../domain/objective/objective_migration.dart';
import '../../../domain/objective/objective_state.dart';
import '../../../domain/objective/temporary/temporary_objectives.dart';
import '../../extensions/objective_extensions.dart';
import '../../extensions/temporary_objective_kind_extensions.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_extension.dart';
import '../common/sheet_drag_handle.dart';
import 'objective_row.dart';

/// Opens the modal bottom sheet of every objective of [player].
Future<void> showObjectivesSheet(
  BuildContext context, {
  required Game game,
  required Player player,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => ObjectivesSheetBody(game: game, player: player),
  );
}

/// Body of the objectives sheet: the temporary objectives of the events,
/// then the six chapters in order, each objective done, current or to do.
/// Only the current objective has its progress computed.
class ObjectivesSheetBody extends StatelessWidget {
  final Game game;
  final Player player;

  const ObjectivesSheetBody({
    super.key,
    required this.game,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    final state = ObjectiveMigration.stateOf(game, player);
    final current = CurrentObjective.of(game, player);
    final temporary = TemporaryObjectives.activeOf(game, player);
    final l10n = context.l10n;
    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            const SheetDragHandle(),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                l10n.objectiveSheetTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  if (temporary.isNotEmpty) ...[
                    _header(context, l10n.objectiveEventHeader),
                    for (final objective in temporary)
                      ObjectiveRow(
                        title: objective.displayTitle(l10n),
                        status: ObjectiveStatus.temporary,
                      ),
                  ],
                  for (final chapter in ObjectiveChapter.values) ...[
                    _header(context, chapter.numberedTitle(l10n)),
                    for (final objective in ObjectiveCatalog.ofChapter(chapter))
                      _row(l10n, objective, state, current),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    AppLocalizations l10n,
    Objective objective,
    ObjectiveState state,
    Objective? current,
  ) {
    final isCurrent = objective.id == current?.id;
    return ObjectiveRow(
      title: objective.displayTitle(l10n),
      status:
          state.isCompleted(objective.id)
              ? ObjectiveStatus.done
              : isCurrent
              ? ObjectiveStatus.current
              : ObjectiveStatus.toDo,
      progress: isCurrent ? objective.progressOf(game, player) : null,
      reward: objective.reward,
    );
  }

  Widget _header(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 4),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}
