import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/map/post_holder.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/presentation/extensions/random_event_type_extensions.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_scatter.dart';

void main() {
  MapCell cellWith(CellContentType content,
          {String? collectedBy, String? passageName}) =>
      MapCell(
        terrain: TerrainType.plain,
        content: content,
        collectedBy: collectedBy,
        passageName: passageName,
        lair: content == CellContentType.monsterLair
            ? const MonsterLair(
                difficulty: MonsterDifficulty.hard, unitCount: 100)
            : null,
        transitionBase: content == CellContentType.transitionBase
            ? TransitionBase(type: TransitionBaseType.faille, name: 'F')
            : null,
      );

  group('MapCellVisual.from', () {
    test('unrevealed cell hides content and glow', () {
      final v = MapCellVisual.from(
        cellWith(CellContentType.transitionBase),
        at: (3, 5),
        isRevealed: false,
        hasPendingExploration: true,
      );
      expect(v.revealed, isFalse);
      expect(v.contentSprite, isNull);
      expect(v.glow, MapGlow.none);
      expect(v.pending, isTrue);
      expect(v.terrainSprite, floorTileOf(TerrainType.plain, (3, 5)));
    });

    test('revealed resource bonus shows its sprite, not dimmed', () {
      final v = MapCellVisual.from(
        cellWith(CellContentType.resourceBonus),
        at: (0, 0),
        isRevealed: true,
      );
      expect(v.contentSprite, 'assets/icons/map_content/resource_bonus.svg');
      expect(v.dimmed, isFalse);
    });

    test('collected content is dimmed', () {
      final v = MapCellVisual.from(
        cellWith(CellContentType.ruins, collectedBy: 'someone'),
        at: (0, 0),
        isRevealed: true,
      );
      expect(v.dimmed, isTrue);
    });

    test('base cell shows the player base sprite', () {
      final v = MapCellVisual.from(
        cellWith(CellContentType.empty),
        at: (0, 0),
        isRevealed: true,
        isBase: true,
      );
      expect(v.contentSprite, playerBaseSvgPath);
    });

    test('monster lair uses its difficulty sprite', () {
      final v = MapCellVisual.from(
        cellWith(CellContentType.monsterLair),
        at: (0, 0),
        isRevealed: true,
      );
      expect(v.contentSprite, 'assets/icons/map_content/monster_hard.svg');
    });

    test('a passage shows the arrival lit by who holds the post above', () {
      final v = MapCellVisual.from(
        cellWith(CellContentType.passage, passageName: 'cheminee:0'),
        at: (0, 0),
        isRevealed: true,
        postHolder: PostHolder.faction,
      );
      expect(v.contentSprite, 'assets/icons/posts/passage_cheminee_faction.svg');
      expect(v.glow, MapGlow.post);
    });

    test('a passage of an unknown post is a guarded Faille arrival', () {
      final v = MapCellVisual.from(
        cellWith(CellContentType.passage),
        at: (0, 0),
        isRevealed: true,
      );
      expect(v.contentSprite, 'assets/icons/posts/passage_faille_guarded.svg');
    });

    test('a transition base shows the illustration of its holder', () {
      final cell = cellWith(CellContentType.transitionBase);
      String? sprite(PostHolder? holder) => MapCellVisual.from(cell,
              at: (0, 0),
              isRevealed: true, postHolder: holder)
          .contentSprite;
      expect(sprite(null), 'assets/icons/posts/faille_guarded.svg');
      expect(sprite(PostHolder.human), 'assets/icons/posts/faille_player.svg');
      expect(sprite(PostHolder.faction), 'assets/icons/posts/faille_faction.svg');
      expect(MapCellVisual.from(cell, at: (0, 0), isRevealed: true).glow,
          MapGlow.post);
    });

    test('a hidden wreck shows through the fog with its halo', () {
      final v = MapCellVisual.from(
        cellWith(CellContentType.wreck),
        at: (0, 0),
        isRevealed: false,
      );
      expect(v.revealed, isFalse);
      expect(v.contentSprite, RandomEventType.wreck.illustration);
      expect(v.glow, MapGlow.wreck);
      expect(v.aboveFog, isTrue);
    });

    test('a revealed wreck keeps its sprite and halo, under no fog', () {
      final v = MapCellVisual.from(
        cellWith(CellContentType.wreck),
        at: (0, 0),
        isRevealed: true,
      );
      expect(v.contentSprite, RandomEventType.wreck.illustration);
      expect(v.glow, MapGlow.wreck);
      expect(v.aboveFog, isFalse);
    });

    test('a searched wreck is dimmed and loses its halo', () {
      final v = MapCellVisual.from(
        cellWith(CellContentType.wreck, collectedBy: 'someone'),
        at: (0, 0),
        isRevealed: true,
      );
      expect(v.dimmed, isTrue);
      expect(v.glow, MapGlow.none);
    });

    test('other hidden contents never show through the fog', () {
      for (final content in CellContentType.values) {
        if (content == CellContentType.wreck) continue;
        final v = MapCellVisual.from(cellWith(content),
            at: (0, 0), isRevealed: false);
        expect(v.aboveFog, isFalse, reason: content.name);
        expect(v.contentSprite, isNull, reason: content.name);
      }
    });

    test('equal inputs give equal visuals', () {
      final cell = cellWith(CellContentType.ruins);
      expect(
        MapCellVisual.from(cell, at: (0, 0), isRevealed: true),
        MapCellVisual.from(cell, at: (0, 0), isRevealed: true),
      );
    });
  });
}
