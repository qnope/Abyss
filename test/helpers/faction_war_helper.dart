import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/faction/faction_turn.dart';
import 'package:abyss/domain/faction/faction_war.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/objective/objective_migration.dart';

import 'base_attack_helper.dart';

class War {
  final Game game;
  final Player attacker;
  final Player rival;
  final Player human;

  War(this.game)
    : attacker = game.players[game.factions[0].id]!,
      rival = game.players[game.factions[1].id]!,
      human = game.humanPlayer;

  /// The faction plays its war on the first turn its slot comes.
  void play() => FactionWar.play(
    FactionTurn(
      game: game,
      player: attacker,
      executor: ActionExecutor(),
      seeds: Random(2),
    ),
    game.factions[0].personality,
  );

  void see(Player base) =>
      attacker.addRevealedCell(1, GridPosition(x: base.baseX, y: base.baseY));
}

War warGame({int from = 12}) {
  final game = GameFactory.newGame(
    playerName: 'Nemo',
    mapSeed: 7,
    factionCount: 2,
  );
  game.turn = from;
  while (!FactionWar.isDue(game.turn, game.factions[0].personality)) {
    game.turn++;
  }
  final war = War(game);
  ObjectiveMigration.stateOf(game, war.human).tutorialEnabled = false;
  station(war.attacker, horde);
  station(war.human, {});
  station(war.rival, {});
  return war;
}
