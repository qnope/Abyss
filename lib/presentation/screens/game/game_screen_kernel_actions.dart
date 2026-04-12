import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/game/game.dart';
import 'fight/kernel_army_selection_screen.dart';

void handleAttackVolcanicKernel(
  BuildContext context,
  Game game,
  GameRepository repository,
  int x,
  int y,
  int level,
  VoidCallback onChanged,
) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => KernelArmySelectionScreen(
        game: game,
        repository: repository,
        targetX: x,
        targetY: y,
        level: level,
        onChanged: onChanged,
      ),
    ),
  );
}
