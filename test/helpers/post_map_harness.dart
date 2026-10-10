import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/objective/objective_migration.dart';
import 'package:abyss/domain/unit/unit_type.dart';

/// A game against one faction at turn 12, the tutorial over, where the
/// faction holds a Faille the human has seen, and the human has a strong
/// army on the base level.
({Game game, Player owner, GridPosition at, TransitionBase post}) postGame({
  int turn = 12,
}) {
  final game = GameFactory.newGame(
    playerName: 'Nemo',
    mapSeed: 7,
    factionCount: 1,
  )..turn = turn;
  ObjectiveMigration.stateOf(game, game.humanPlayer).tutorialEnabled = false;
  final owner = game.players[game.factions.first.id]!;
  final map = game.levels[1]!;
  for (var y = 0; y < map.height; y++) {
    for (var x = 0; x < map.width; x++) {
      final base = map.cellAt(x, y).transitionBase;
      if (base != null && base.type == TransitionBaseType.faille) {
        base.capturedBy = owner.id;
        final at = GridPosition(x: x, y: y);
        game.humanPlayer.addRevealedCell(1, at);
        game.humanPlayer.unitsOnLevel(1)[UnitType.harpoonist]!.count = 60;
        return (game: game, owner: owner, at: at, post: base);
      }
    }
  }
  throw StateError('no Faille on level 1');
}
