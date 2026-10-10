import 'package:flutter/material.dart';

import '../../../data/game_repository.dart';
import '../../../domain/game/game.dart';
import '../../../domain/game/game_status.dart';
import 'game_screen.dart';
import 'game_screen_defeat_actions.dart';

/// Reopens a saved [game] where it was left, as the only screen: a lost
/// game reopens on its defeat screen.
void resumeGame(BuildContext context, Game game, GameRepository repository) {
  if (game.status == GameStatus.defeat) {
    showDefeatScreen(context, game, repository);
    return;
  }
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(
      builder: (_) => GameScreen(game: game, repository: repository),
    ),
    (_) => false,
  );
}
