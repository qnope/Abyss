import 'package:abyss/data/game_repository.dart';
import 'package:abyss/domain/faction/faction.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/objective/objective_migration.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/game_screen_map_actions.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:flutter/material.dart';

import 'fake_game_repository.dart';

/// A game against one faction at turn 12, the tutorial over, the faction
/// base seen and a strong army standing on the human's base level.
Game factionAttackGame({int turn = 12, bool revealed = true}) {
  final game = GameFactory.newGame(
    playerName: 'Nemo',
    mapSeed: 7,
    factionCount: 1,
  )..turn = turn;
  ObjectiveMigration.stateOf(game, game.humanPlayer).tutorialEnabled = false;
  final Player target = factionPlayer(game);
  if (revealed) {
    game.humanPlayer.addRevealedCell(
      1,
      GridPosition(x: target.baseX, y: target.baseY),
    );
  }
  game.humanPlayer.unitsOnLevel(1)[UnitType.harpoonist]!.count = 40;
  return game;
}

Faction firstFaction(Game game) => game.factions.first;

Player factionPlayer(Game game) => game.players[firstFaction(game).id]!;

/// The map tab of [game] in a themed, localized app.
Widget factionMapHost(
  Game game, {
  GameRepository? repository,
  VoidCallback? onChanged,
}) => MaterialApp(
  theme: AbyssTheme.create(),
  locale: AbyssLocale.fr,
  localizationsDelegates: AbyssLocale.delegates,
  supportedLocales: AbyssLocale.supported,
  home: Scaffold(
    body: Builder(
      builder: (context) => buildMapTab(
        context,
        game,
        repository ?? FakeGameRepository(),
        currentLevel: 1,
        unlockedLevels: game.levels.keys.toSet(),
        onLevelSelected: (_) {},
        onChanged: onChanged ?? () {},
      ),
    ),
  ),
);
