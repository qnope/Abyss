import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/exploration_order.dart';
import 'package:abyss/domain/map/exploration_resolver.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a scout seeing a corner of the volcano reveals all of it', () {
    final map = MapGenerator.generate(seed: 5, level: 3).map;
    final player = Player(
      name: 'p',
      pendingExplorations: [
        ExplorationOrder(target: GridPosition(x: 12, y: 12), level: 3),
      ],
    );
    final game = Game(
      humanPlayerId: player.id,
      players: {player.id: player},
      levels: {3: map},
    );
    ExplorationResolver.resolve(game);
    final seen = player.revealedCellsSetOnLevel(3);
    expect(seen, contains(GridPosition(x: 10, y: 10)));
    expect(map.cellAt(10, 10).content, CellContentType.volcanicKernel);
  });
}
