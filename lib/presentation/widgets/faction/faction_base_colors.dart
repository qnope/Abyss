import 'package:flutter/painting.dart';

import '../../../domain/game/game.dart';
import '../../../domain/map/grid_position.dart';
import '../../theme/abyss_colors.dart';
import '../../theme/faction_colors.dart';

/// The colour of each faction base of [game] on the first level, by
/// position. Empty in a game without factions.
Map<GridPosition, Color> factionBaseColors(Game game) => {
  for (final faction in game.factions)
    if (game.players[faction.id] case final player?)
      GridPosition(x: player.baseX, y: player.baseY): FactionColors.of(
        faction.personality,
      ),
};

/// The seal colour of each player who can hold the volcano: the human in
/// the cyan of their base, each faction in its own colour.
Map<String, Color> kernelOwnerColors(Game game) => {
  game.humanPlayerId: AbyssColors.biolumCyan,
  for (final faction in game.factions)
    faction.id: FactionColors.of(faction.personality),
};
