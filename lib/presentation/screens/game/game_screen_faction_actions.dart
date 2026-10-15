import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/action/action_executor.dart';
import '../../../domain/action/attack_base_validator.dart';
import '../../../domain/action/spy_base_action.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/faction/faction.dart';
import '../../../domain/game/game.dart';
import '../../../domain/game/player.dart';
import '../../../domain/action/attack_held_kernel_validator.dart';
import '../../../domain/action/attack_post_validator.dart';
import '../../../domain/volcano/kernel_garrison.dart';
import '../../../domain/map/transition_base.dart';
import '../../widgets/faction/faction_base_sheet.dart';
import '../../widgets/map/effects/map_effects.dart';
import '../../widgets/map/rival_post_sheet.dart';
import 'game_screen_rival_attack.dart';

/// The faction whose base stands on ([x], [y]) of the first level, if any.
Faction? factionBaseAt(Game game, int x, int y) {
  for (final faction in game.factions) {
    final player = game.players[faction.id];
    if (player != null && player.baseX == x && player.baseY == y) {
      return faction;
    }
  }
  return null;
}

/// Opens the sheet of the base of [faction]; its attack button leads to
/// the army selection, and the assault plays on the map through [effects].
void openFactionBaseSheet(
  BuildContext context,
  Game game,
  GameRepository repository,
  Faction faction,
  VoidCallback onChanged, {
  MapEffects? effects,
}) {
  final Player target = game.players[faction.id]!;
  showFactionBaseSheet(
    context,
    faction: faction,
    headquartersLevel: target.buildings[BuildingType.headquarters]!.level,
    refusal: AttackBaseValidator.refusal(game, game.humanPlayer, target.id),
    intel: game.humanPlayer.intel[target.id],
    turn: game.turn,
    spyRefusal: SpyBaseAction.refusal(game, game.humanPlayer, target.id),
    onSpy: () {
      ActionExecutor().execute(
        SpyBaseAction(targetPlayerId: target.id),
        game,
        game.humanPlayer,
      );
      repository.save(game);
      onChanged();
      if (context.mounted) {
        openFactionBaseSheet(context, game, repository, faction, onChanged,
            effects: effects);
      }
    },
    onAttack: () => handleRivalAssault(
        context, game, repository, target, onChanged, effects: effects),
  );
}

/// Opens the sheet of the [post] at ([x], [y]) of [level] that another
/// player holds; its attack button leads to the army selection of the
/// level; the assault plays on the map through [effects].
void openRivalPostSheet(
  BuildContext context,
  Game game,
  GameRepository repository,
  TransitionBase post,
  int x,
  int y,
  int level,
  VoidCallback onChanged, {
  MapEffects? effects,
}) {
  final Player owner = game.players[post.capturedBy]!;
  showRivalPostSheet(
    context,
    post: post,
    ownerName: owner.name,
    refusal: AttackPostValidator.refusal(game, game.humanPlayer, level, x, y),
    onAttack: () => handleRivalAssault(
        context, game, repository, owner, onChanged,
        post: (x: x, y: y, level: level), effects: effects),
  );
}

/// Opens the sheet of the volcanic kernel at ([x], [y]) that another
/// player holds; its attack button leads to the army selection of the
/// volcano level; the assault plays on the map through [effects].
void openRivalKernelSheet(
  BuildContext context,
  Game game,
  GameRepository repository,
  int x,
  int y,
  VoidCallback onChanged, {
  MapEffects? effects,
}) {
  final Player owner = game.players[game.levels[KernelGarrison.volcanoLevel]!
      .cellAt(x, y)
      .collectedBy]!;
  showRivalPostSheet(
    context,
    post: null,
    ownerName: owner.name,
    refusal: AttackHeldKernelValidator.refusal(game, game.humanPlayer, x, y),
    onAttack: () => handleRivalAssault(
        context, game, repository, owner, onChanged,
        post: (x: x, y: y, level: KernelGarrison.volcanoLevel),
        kernel: true, effects: effects),
  );
}
