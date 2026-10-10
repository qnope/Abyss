import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/turn/turn_resolver.dart';
import 'package:abyss/presentation/screens/game/game_screen_turn_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

/// A 2x2 map whose first cell holds a [type] base captured by [owner].
GameMap _map(TransitionBaseType type, String? owner) => GameMap(
      width: 2,
      height: 2,
      seed: 1,
      cells: [
        MapCell(
          terrain: TerrainType.plain,
          content: CellContentType.transitionBase,
          transitionBase:
              TransitionBase(type: type, name: type.name, capturedBy: owner),
        ),
        for (var i = 1; i < 4; i++) MapCell(terrain: TerrainType.plain),
      ],
    );

/// Game of player `p` holding a Faille on level 1 and a Cheminee on
/// level 2 owned by [chimneyOwner].
Game _game({String? chimneyOwner = 'p'}) => Game(
      humanPlayerId: 'p',
      players: {'p': Player(id: 'p', name: 'Nemo', baseX: 1, baseY: 1)},
      levels: {
        1: _map(TransitionBaseType.faille, 'p'),
        2: _map(TransitionBaseType.cheminee, chimneyOwner),
      },
    );

int _previewPearls(Game game) =>
    computeProduction(game, game.humanPlayer)[ResourceType.pearl] ?? 0;

void main() {
  test('the preview adds the pearls of every held transition base', () {
    expect(_previewPearls(_game()), 2 + 3);
  });

  test('the preview leaves out the bases held by someone else', () {
    expect(_previewPearls(_game(chimneyOwner: 'rival')), 2);
  });

  test('the previewed pearls are the ones the end of turn credits', () {
    final game = _game();
    final preview = _previewPearls(game);
    final result = TurnResolver().resolve(game);
    final change =
        result.changes.firstWhere((c) => c.type == ResourceType.pearl);
    expect(change.produced, preview);
  });
}
