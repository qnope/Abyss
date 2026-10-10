import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/game/player.dart';

/// A two-player game on one map: the human on the generated base and a
/// rival standing on a base of its own, a few cells away.
class TwoPlayerGame {
  final Game game;
  final Player human;
  final Player rival;

  TwoPlayerGame._(this.game, this.human, this.rival);

  factory TwoPlayerGame.create({int mapSeed = 3, String? rivalId}) {
    final Game game = GameFactory.newSinglePlayer(
      playerName: 'human',
      mapSeed: mapSeed,
    );
    final int width = game.levels[1]!.width;
    final int height = game.levels[1]!.height;
    final Player human = game.humanPlayer;
    final Player rival = Player.withBase(
      id: rivalId,
      name: 'rival',
      baseX: (human.baseX + width ~/ 2) % width,
      baseY: (human.baseY + height ~/ 2) % height,
      mapWidth: width,
      mapHeight: height,
    );
    game.players[rival.id] = rival;
    return TwoPlayerGame._(game, human, rival);
  }
}
