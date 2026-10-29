import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/post_holder.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/presentation/extensions/post_holder_extensions.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_flat_contents.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the Faille and every passage lie flat, in every light', () {
    for (final holder in PostHolder.values) {
      expect(isFlatContent(TransitionBaseType.faille.svgPathFor(holder)),
          isTrue, reason: holder.name);
      for (final type in TransitionBaseType.values) {
        expect(isFlatContent(type.passageSvgPathFor(holder)), isTrue,
            reason: '${type.name} ${holder.name}');
      }
    }
  });

  test('the Cheminée and other contents stand', () {
    for (final holder in PostHolder.values) {
      expect(isFlatContent(TransitionBaseType.cheminee.svgPathFor(holder)),
          isFalse, reason: holder.name);
    }
    expect(isFlatContent(playerBaseSvgPath), isFalse);
    expect(isFlatContent(null), isFalse);
  });

  group('a cell visual', () {
    const plain = 'plain.svg';

    test('of a Faille lies flat, its glow still shows', () {
      final faille = MapCellVisual.from(
        MapCell(
          terrain: TerrainType.plain,
          content: CellContentType.transitionBase,
          transitionBase:
              TransitionBase(type: TransitionBaseType.faille, name: 'F'),
        ),
        at: (0, 0),
        isRevealed: true,
      );
      expect(faille.liesFlat, isTrue);
      expect(faille.standsUp, isFalse);
      expect(faille.onStandingLayer, isTrue);
    });

    test('of a base stands up', () {
      const base = MapCellVisual(
          terrainSprite: plain, contentSprite: playerBaseSvgPath);
      expect(base.liesFlat, isFalse);
      expect(base.standsUp, isTrue);
      expect(base.onStandingLayer, isTrue);
    });

    test('of an empty cell leaves the standing layer empty', () {
      const empty = MapCellVisual(terrainSprite: plain, revealed: true);
      expect(empty.liesFlat, isFalse);
      expect(empty.standsUp, isFalse);
      expect(empty.onStandingLayer, isFalse);
    });

    test('of a faction base not drawn yet still wears its ring', () {
      const ring = MapCellVisual(
          terrainSprite: plain, factionColor: Color(0xFFFF0000));
      expect(ring.onStandingLayer, isTrue);
    });
  });
}
