import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/action/attack_base_validator.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/faction/faction.dart';
import '../../../domain/game/game.dart';
import '../../../domain/game/player.dart';
import '../../widgets/faction/faction_base_sheet.dart';
import 'fight/base_army_selection_screen.dart';

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
/// the army selection.
void openFactionBaseSheet(
  BuildContext context,
  Game game,
  GameRepository repository,
  Faction faction,
  VoidCallback onChanged,
) {
  final Player target = game.players[faction.id]!;
  showFactionBaseSheet(
    context,
    faction: faction,
    headquartersLevel: target.buildings[BuildingType.headquarters]!.level,
    refusal: AttackBaseValidator.refusal(game, game.humanPlayer, target.id),
    onAttack: () => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BaseArmySelectionScreen(
          game: game,
          repository: repository,
          target: target,
          onChanged: onChanged,
        ),
      ),
    ),
  );
}
