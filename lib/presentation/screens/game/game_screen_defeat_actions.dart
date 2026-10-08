import 'package:flutter/material.dart';

import '../../../data/game_repository.dart';
import '../../../domain/game/game.dart';
import '../../../domain/game/game_statistics_calculator.dart';
import '../../widgets/common/replay_export_dialog.dart';
import '../menu/main_menu_screen.dart';
import 'defeat_screen.dart';

/// Route to the defeat screen of a lost [game]. The game is over: the
/// only way out is the main menu.
Route<void> defeatRoute(Game game, GameRepository repository) {
  return MaterialPageRoute<void>(
    builder: (context) => DefeatScreen(
      statistics: const GameStatisticsCalculator().compute(game),
      fallTurn: game.turn - 1,
      onExport: () => showReplayExportDialog(context, game),
      onReturnToMenu: () => Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => MainMenuScreen(repository: repository),
        ),
        (_) => false,
      ),
    ),
  );
}

/// Replaces every screen with the defeat screen of [game].
Future<void> showDefeatScreen(
  BuildContext context,
  Game game,
  GameRepository repository,
) {
  return Navigator.of(context)
      .pushAndRemoveUntil(defeatRoute(game, repository), (_) => false);
}
