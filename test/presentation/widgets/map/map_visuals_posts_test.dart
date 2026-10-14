import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/post_holder.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:abyss/presentation/widgets/map/map_visuals_builder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/map_tab_harness.dart';

void main() {
  final post = GridPosition(x: 1, y: 1);
  final passage = GridPosition(x: 4, y: 2);
  int indexOf(GridPosition p) => p.y * harnessMapSize + p.x;

  final map = plainMap({
    post: MapCell(
      terrain: TerrainType.plain,
      content: CellContentType.transitionBase,
      transitionBase: TransitionBase(
          type: TransitionBaseType.cheminee, name: 'cheminee:0',
          capturedBy: 'me'),
    ),
    passage: MapCell(
      terrain: TerrainType.plain,
      content: CellContentType.passage,
      passageName: 'faille:1',
    ),
  });

  final visuals = buildMapVisuals(
    gameMap: map,
    revealedCells: {post, passage},
    humanPlayerId: 'me',
    passageHolders: {passage: PostHolder.faction},
  );

  test('a post the human holds is lit green', () {
    expect(visuals[indexOf(post)].contentSprite,
        'assets/icons/posts/cheminee_player.svg');
  });

  test('a passage is lit by the holder of the post above', () {
    expect(visuals[indexOf(passage)].contentSprite,
        'assets/icons/posts/passage_faille_faction.svg');
  });

  test('the map preloads every post illustration', () {
    expect(MapSprites.svgPaths,
        containsAll(['assets/icons/posts/faille_guarded.svg',
          'assets/icons/posts/passage_cheminee_faction.svg']));
  });
}
