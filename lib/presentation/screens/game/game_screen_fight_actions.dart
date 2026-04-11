import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/game/game.dart';
import '../../../domain/map/monster_lair.dart';
import 'fight/army_selection_screen.dart';

void openArmySelection(
  BuildContext context,
  Game game,
  GameRepository repository,
  int x,
  int y,
  MonsterLair lair,
  VoidCallback onChanged, {
  required int level,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ArmySelectionScreen(
        game: game,
        repository: repository,
        targetX: x,
        targetY: y,
        level: level,
        lair: lair,
        onChanged: onChanged,
      ),
    ),
  );
}
