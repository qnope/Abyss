import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/action/fight_monster_result.dart';
import '../../../domain/game/game.dart';
import '../../../domain/map/monster_lair.dart';
import '../../widgets/map/effects/map_effects.dart';
import '../../widgets/map/effects/strike/map_strike.dart';
import 'fight/army_selection_screen.dart';
import 'fight/fight_summary_screen.dart';

/// Lets the player choose an army and attack [lair] at ([x], [y]); the
/// attack then plays on the map through [effects], before its report.
Future<void> openArmySelection(
  BuildContext context,
  Game game,
  GameRepository repository,
  int x,
  int y,
  MonsterLair lair,
  VoidCallback onChanged, {
  required int level,
  MapEffects? effects,
}) async {
  final navigator = Navigator.of(context);
  final result = await navigator.push<FightMonsterResult>(
    MaterialPageRoute(
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
  if (result == null) return;
  if (result.isSuccess) {
    await effects?.strike(
        MapStrike.of(target: (x, y), lair: lair, result: result));
  }
  if (!navigator.mounted) return;
  await navigator.push(MaterialPageRoute<void>(
    builder: (_) => FightSummaryScreen(
        result: result, lair: lair, targetX: x, targetY: y),
  ));
}
