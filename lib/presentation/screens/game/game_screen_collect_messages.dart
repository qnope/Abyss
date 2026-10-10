import 'package:flutter/widgets.dart';

import '../../../domain/action/action_executor.dart';
import '../../../domain/action/collect_treasure_action.dart';
import '../../../domain/action/collect_treasure_result.dart';
import '../../../domain/game/game.dart';
import '../../../domain/map/cell_content_type.dart';
import '../../../domain/replay/seeded_random.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_extension.dart';
import '../../widgets/resource/resource_gain_dialog.dart';

/// Title of the dialog telling what a collect of [content] found.
String titleFor(AppLocalizations l10n, CellContentType content) =>
    switch (content) {
      CellContentType.resourceBonus => l10n.screenTreasureCollected,
      CellContentType.ruins => l10n.screenRuinsSearched,
      CellContentType.wreck => l10n.screenWreckSearched,
      _ => l10n.screenCollectTitle,
    };

/// What the dialog says when a collect of [content] found nothing.
String emptyMessageFor(AppLocalizations l10n, CellContentType content) =>
    switch (content) {
      CellContentType.ruins => l10n.screenRuinsEmpty,
      CellContentType.wreck => l10n.screenWreckEmpty,
      _ => l10n.screenNothingToCollect,
    };

/// Collects the treasure, ruins or wreck at ([x], [y]) and shows what it
/// gave.
void collectTreasure(BuildContext context, Game game, int x, int y,
    int level, CellContentType content, VoidCallback onChanged) {
  final action = CollectTreasureAction(
      targetX: x, targetY: y, level: level, random: SeededRandom.fresh());
  final result = ActionExecutor().execute(action, game, game.humanPlayer);
  if (!result.isSuccess) return;
  onChanged();
  if (result is! CollectTreasureResult) return;
  final l10n = context.l10n;
  showResourceGainDialog(context,
      title: titleFor(l10n, content),
      deltas: result.deltas,
      emptyMessage: emptyMessageFor(l10n, content));
}
