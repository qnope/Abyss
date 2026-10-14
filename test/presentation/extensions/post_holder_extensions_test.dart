import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/post_holder.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/presentation/extensions/post_holder_extensions.dart';

void main() {
  test('each post has its illustration for each holder', () {
    expect(TransitionBaseType.faille.svgPathFor(PostHolder.guardians),
        'assets/icons/posts/faille_guarded.svg');
    expect(TransitionBaseType.faille.svgPathFor(PostHolder.human),
        'assets/icons/posts/faille_player.svg');
    expect(TransitionBaseType.cheminee.svgPathFor(PostHolder.faction),
        'assets/icons/posts/cheminee_faction.svg');
  });

  test('each passage below has its illustration for each holder', () {
    expect(TransitionBaseType.faille.passageSvgPathFor(PostHolder.human),
        'assets/icons/posts/passage_faille_player.svg');
    expect(TransitionBaseType.cheminee.passageSvgPathFor(PostHolder.guardians),
        'assets/icons/posts/passage_cheminee_guarded.svg');
  });

  test('every path points to an existing asset', () {
    for (final path in postSvgPaths) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }
    expect(postSvgPaths, hasLength(12));
  });

  test('a passage is lit by the post right above it', () {
    final cells = List.generate(4, (_) => MapCell(terrain: TerrainType.plain));
    final above = GameMap(width: 2, height: 2, cells: cells, seed: 1)
      ..setCell(1, 0, MapCell(
        terrain: TerrainType.plain,
        content: CellContentType.transitionBase,
        transitionBase: TransitionBase(
            type: TransitionBaseType.cheminee, name: 'cheminee:1',
            capturedBy: 'me'),
      ));
    expect(passageIllustration(above, 1, 0, 'me', 'cheminee:1'),
        'assets/icons/posts/passage_cheminee_player.svg');
    expect(passageIllustration(null, 1, 0, 'me', null),
        'assets/icons/posts/passage_faille_guarded.svg');
  });
}
