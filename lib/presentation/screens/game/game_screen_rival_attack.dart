import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/action/attack_base_entries.dart';
import '../../../domain/action/attack_base_result.dart';
import '../../../domain/action/attack_held_kernel_action.dart';
import '../../../domain/game/game.dart';
import '../../../domain/game/player.dart';
import '../../../domain/map/cell_content_type.dart';
import '../../../domain/map/post_holder.dart';
import '../../../domain/map/volcanic_kernel_placer.dart';
import '../../extensions/cell_content_type_extensions.dart';
import '../../extensions/post_holder_extensions.dart';
import '../../widgets/map/effects/map_effects.dart';
import '../../widgets/map/effects/strike/map_strike.dart';
import '../../widgets/map/map_cell_visual.dart';
import 'fight/base_army_selection_screen.dart';
import 'fight/base_assault_summary_screen.dart';

/// Where a rival's post stands: a Faille, a Cheminée, or the volcano.
typedef RivalPost = ({int x, int y, int level});

/// Lets the player choose an army and assault the base of [target], or
/// with [post] the Faille or Cheminée it holds there (the volcano with
/// [kernel]); the assault then plays on the map through [effects], before
/// its report.
Future<void> handleRivalAssault(
  BuildContext context,
  Game game,
  GameRepository repository,
  Player target,
  VoidCallback onChanged, {
  RivalPost? post,
  bool kernel = false,
  MapEffects? effects,
}) async {
  final navigator = Navigator.of(context);
  final result = await navigator.push<AttackBaseResult>(
    MaterialPageRoute(
      builder: (_) => BaseArmySelectionScreen(
        game: game,
        repository: repository,
        target: target,
        post: post,
        kernel: kernel,
        onChanged: onChanged,
      ),
    ),
  );
  if (result == null) return;
  await effects?.strike(MapStrike.onBase(
    target: post == null ? (target.baseX, target.baseY) : (post.x, post.y),
    sprite: _spriteOf(game, post, kernel: kernel),
    result: result,
    span: kernel ? VolcanicKernelPlacer.side : 1,
  ));
  if (!navigator.mounted) return;
  await navigator.push(MaterialPageRoute<void>(
    builder: (_) => BaseAssaultSummaryScreen(
      entry: AttackBaseEntries.forAttacker(
        game.turn,
        target.name,
        result,
        postName: post == null ? null : _postName(game, post, kernel: kernel),
      ),
    ),
  ));
}

/// The sprite the map draws for what was assaulted, as it now stands.
String _spriteOf(Game game, RivalPost? post, {required bool kernel}) {
  if (post == null) return playerBaseSvgPath;
  if (kernel) return CellContentType.volcanicKernel.svgPath!;
  final base = game.levels[post.level]!.cellAt(post.x, post.y).transitionBase!;
  return base.type.svgPathFor(PostHolder.of(base, game.humanPlayerId));
}

String _postName(Game game, RivalPost post, {required bool kernel}) => kernel
    ? AttackHeldKernelAction.kernelCode
    : game.levels[post.level]!.cellAt(post.x, post.y).transitionBase!.name;
