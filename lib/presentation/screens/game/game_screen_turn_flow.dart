import 'package:flutter/material.dart';

import '../../../data/game_repository.dart';
import '../../../domain/game/game.dart';
import '../../../domain/game/game_status.dart';
import '../../../domain/turn/turn_result.dart';
import '../../widgets/tip/tip_presenter.dart';
import '../../widgets/turn/turn_summary_dialog.dart';
import 'game_screen_defeat_actions.dart';
import 'game_screen_event_actions.dart';
import 'raid/raid_summary_screen.dart';
import 'volcano/volcano_summary_screen.dart';

/// Everything shown once a turn has ended, one after the other: the
/// summary, the reports of the raid, of the predators and of a lost
/// kraken wave, the card of the event drawn, then the defeat if any, or
/// else the next tip of [tips].
Future<void> showTurnOutcome(
  BuildContext context,
  Game game,
  GameRepository repository,
  TurnResult result,
  VoidCallback onChanged, {
  TipPresenter? tips,
}) async {
  await showTurnSummaryDialog(context, result: result);
  for (final report in [result.raid, result.predators]) {
    if (report != null && context.mounted) {
      await RaidSummaryScreen.open(context, report);
    }
  }
  final wave = result.volcano;
  if (wave != null && !wave.victory && context.mounted) {
    await VolcanoSummaryScreen.open(context, wave);
  }
  final defeated = game.status == GameStatus.defeat;
  final event = result.event;
  if (event != null && !defeated && context.mounted) {
    await openEventCard(context, game, repository, event, onChanged);
  }
  if (!context.mounted) return;
  if (defeated) {
    await showDefeatScreen(context, game, repository);
  } else {
    await tips?.showNext(context);
  }
}
