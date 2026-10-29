import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/ambience/ambient_motion.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MapCell cellWith(CellContentType content, {String? collectedBy}) => MapCell(
        terrain: TerrainType.plain,
        content: content,
        collectedBy: collectedBy,
        lair: content == CellContentType.monsterLair
            ? const MonsterLair(
                difficulty: MonsterDifficulty.easy, unitCount: 10)
            : null,
        transitionBase: content == CellContentType.transitionBase
            ? TransitionBase(type: TransitionBaseType.faille, name: 'F')
            : null,
      );

  AmbientMotion motionOf(CellContentType content,
          {bool revealed = true, bool isBase = false, String? collectedBy}) =>
      MapCellVisual.from(cellWith(content, collectedBy: collectedBy),
              at: (0, 0), isRevealed: revealed, isBase: isBase)
          .motion;

  group('MapCellVisual.motion', () {
    test('monster lairs bob', () {
      expect(motionOf(CellContentType.monsterLair), AmbientMotion.bob);
    });

    test('the player base and faction bases breathe', () {
      expect(motionOf(CellContentType.empty, isBase: true),
          AmbientMotion.breathe);
      final faction = MapCellVisual.from(cellWith(CellContentType.empty),
          at: (0, 0), isRevealed: true, factionColor: AbyssColors.coralPink);
      expect(faction.motion, AmbientMotion.breathe);
    });

    test('posts, passages and the volcano pulse a glow of their own', () {
      for (final content in [
        CellContentType.transitionBase,
        CellContentType.passage,
        CellContentType.volcanicKernel,
      ]) {
        final v = MapCellVisual.from(cellWith(content),
            at: (0, 0), isRevealed: true);
        expect(v.motion, AmbientMotion.pulse, reason: content.name);
        expect(v.glow, isNot(MapGlow.none), reason: content.name);
      }
    });

    test('wrecks, treasures and resource bonuses sway', () {
      expect(motionOf(CellContentType.wreck), AmbientMotion.sway);
      expect(motionOf(CellContentType.wreck, revealed: false),
          AmbientMotion.sway);
      expect(motionOf(CellContentType.ruins), AmbientMotion.sway);
      expect(motionOf(CellContentType.resourceBonus), AmbientMotion.sway);
    });

    test('collected contents, empty and hidden cells stay still', () {
      expect(motionOf(CellContentType.ruins, collectedBy: 'p'),
          AmbientMotion.still);
      expect(motionOf(CellContentType.wreck, collectedBy: 'p'),
          AmbientMotion.still);
      expect(motionOf(CellContentType.empty), AmbientMotion.still);
      expect(motionOf(CellContentType.volcanicKernelPart), AmbientMotion.still);
      expect(motionOf(CellContentType.monsterLair, revealed: false),
          AmbientMotion.still);
    });

    test('the motion is part of equality', () {
      const plain = 'assets/icons/terrain/plain.svg';
      const still = MapCellVisual(terrainSprite: plain);
      const bobbing =
          MapCellVisual(terrainSprite: plain, motion: AmbientMotion.bob);
      expect(bobbing, isNot(still));
      expect(bobbing,
          const MapCellVisual(terrainSprite: plain, motion: AmbientMotion.bob));
      expect(bobbing.hashCode,
          const MapCellVisual(terrainSprite: plain, motion: AmbientMotion.bob)
              .hashCode);
    });
  });
}
