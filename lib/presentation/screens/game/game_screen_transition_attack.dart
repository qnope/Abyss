import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/action/attack_transition_base_result.dart';
import '../../../domain/game/game.dart';
import '../../../domain/map/post_holder.dart';
import '../../../domain/map/transition_base.dart';
import '../../extensions/post_holder_extensions.dart';
import '../../widgets/map/effects/map_effects.dart';
import '../../widgets/map/effects/strike/map_strike.dart';
import 'fight/transition_army_selection_screen.dart';
import 'fight/transition_fight_summary_screen.dart';

/// Lets the player choose an army and assault [transitionBase] at ([x],
/// [y]); the assault then plays on the map through [effects], before its
/// report.
Future<void> handleAttackTransitionBase(
  BuildContext context,
  Game game,
  GameRepository repository,
  TransitionBase transitionBase,
  int x,
  int y,
  int level,
  VoidCallback onChanged, {
  MapEffects? effects,
}) async {
  final navigator = Navigator.of(context);
  final result = await navigator.push<AttackTransitionBaseResult>(
    MaterialPageRoute(
      builder: (_) => TransitionArmySelectionScreen(
        game: game,
        repository: repository,
        targetX: x,
        targetY: y,
        level: level,
        transitionBase: transitionBase,
        onChanged: onChanged,
      ),
    ),
  );
  if (result == null) return;
  if (result.isSuccess) {
    await effects?.strike(MapStrike.onPlace(
      target: (x, y),
      sprite: transitionBase.type.svgPathFor(
          PostHolder.of(transitionBase, game.humanPlayer.id)),
      result: result,
    ));
  }
  if (!navigator.mounted) return;
  await navigator.push(MaterialPageRoute<void>(
    builder: (_) => TransitionFightSummaryScreen(
      result: result,
      transitionBase: transitionBase,
      targetX: x,
      targetY: y,
    ),
  ));
}
