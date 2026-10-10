import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/presentation/extensions/random_event_type_extensions.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';

void main() {
  MapCell cellWith(CellContentType content, {String? collectedBy}) => MapCell(
        terrain: TerrainType.plain,
        content: content,
        collectedBy: collectedBy,
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
        isRevealed: false,
        hasPendingExploration: true,
      );
      expect(v.revealed, isFalse);
      expect(v.contentSprite, isNull);
      expect(v.glow, MapGlow.none);
      expect(v.pending, isTrue);
      expect(v.terrainSprite, 'assets/icons/terrain/plain.svg');
    });

    test('revealed resource bonus shows its sprite, not dimmed', () {
      final v = MapCellVisual.from(
        cellWith(CellContentType.resourceBonus),
        isRevealed: true,
      );
      expect(v.contentSprite, 'assets/icons/map_content/resource_bonus.svg');
      expect(v.dimmed, isFalse);
    });

    test('collected content is dimmed', () {
      final v = MapCellVisual.from(
        cellWith(CellContentType.ruins, collectedBy: 'someone'),
        isRevealed: true,
      );
      expect(v.dimmed, isTrue);
    });

    test('base cell shows the player base sprite', () {
      final v = MapCellVisual.from(
        cellWith(CellContentType.empty),
        isRevealed: true,
        isBase: true,
      );
      expect(v.contentSprite, playerBaseSvgPath);
    });

    test('monster lair uses its difficulty sprite', () {
      final v = MapCellVisual.from(
        cellWith(CellContentType.monsterLair),
        isRevealed: true,
      );
      expect(v.contentSprite, 'assets/icons/map_content/monster_hard.svg');
    });

    test('passage shows the passage glow without sprite', () {
      final v = MapCellVisual.from(
        cellWith(CellContentType.passage),
        isRevealed: true,
      );
      expect(v.glow, MapGlow.passage);
      expect(v.contentSprite, isNull);
    });

    test('transition base glow depends on capture', () {
      final cell = cellWith(CellContentType.transitionBase);
      final hostile = MapCellVisual.from(cell, isRevealed: true);
      final captured = MapCellVisual.from(
        cell,
        isRevealed: true,
        isCapturedTransitionBase: true,
      );
      expect(hostile.glow, MapGlow.hostileBase);
      expect(captured.glow, MapGlow.capturedBase);
    });

    test('a hidden wreck shows through the fog with its halo', () {
      final v = MapCellVisual.from(
        cellWith(CellContentType.wreck),
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
        isRevealed: true,
      );
      expect(v.contentSprite, RandomEventType.wreck.illustration);
      expect(v.glow, MapGlow.wreck);
      expect(v.aboveFog, isFalse);
    });

    test('a searched wreck is dimmed and loses its halo', () {
      final v = MapCellVisual.from(
        cellWith(CellContentType.wreck, collectedBy: 'someone'),
        isRevealed: true,
      );
      expect(v.dimmed, isTrue);
      expect(v.glow, MapGlow.none);
    });

    test('other hidden contents never show through the fog', () {
      for (final content in CellContentType.values) {
        if (content == CellContentType.wreck) continue;
        final v = MapCellVisual.from(cellWith(content), isRevealed: false);
        expect(v.aboveFog, isFalse, reason: content.name);
        expect(v.contentSprite, isNull, reason: content.name);
      }
    });

    test('equal inputs give equal visuals', () {
      final cell = cellWith(CellContentType.ruins);
      expect(
        MapCellVisual.from(cell, isRevealed: true),
        MapCellVisual.from(cell, isRevealed: true),
      );
    });
  });
}
