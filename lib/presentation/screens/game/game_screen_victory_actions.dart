import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/game/game.dart';
import '../../../domain/game/game_statistics_calculator.dart';
import '../../../domain/game/game_status.dart';
import '../menu/main_menu_screen.dart';
import 'victory_screen.dart';

void showVictoryScreen(
  BuildContext context,
  Game game,
  GameRepository repository,
  VoidCallback onChanged,
) {
  final stats = const GameStatisticsCalculator().compute(game);
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => VictoryScreen(
        statistics: stats,
        onContinue: () {
          game.status = GameStatus.freePlay;
          repository.save(game);
          Navigator.of(context).pop();
          onChanged();
        },
        onReturnToMenu: () {
          repository.save(game);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(
              builder: (_) => MainMenuScreen(repository: repository),
            ),
            (_) => false,
          );
        },
      ),
    ),
  );
}
