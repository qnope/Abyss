import 'package:flutter/painting.dart';

import '../../../domain/map/cell_content_type.dart';
import '../../../domain/map/map_cell.dart';
import '../../../domain/map/post_holder.dart';
import '../../../domain/map/volcanic_kernel_placer.dart';
import '../../extensions/cell_content_type_extensions.dart';
import '../../extensions/monster_lair_extensions.dart';
import '../../extensions/post_holder_extensions.dart';
import '../../extensions/terrain_type_extensions.dart';
import '../ambience/ambient_motion.dart';
import 'map_cell_motion.dart';

const playerBaseSvgPath = 'assets/icons/map_content/player_base.svg';
const volcanoSealSvgPath = 'assets/icons/terrain/volcanic_kernel_seal.svg';

/// Glowing marker drawn under a cell's content: the halo of a wreck, or
/// the light a post or the volcano pulses.
enum MapGlow { none, wreck, post, volcano }

/// Everything needed to draw one map cell, decoupled from widgets so the
/// whole map can be painted in a single pass.
class MapCellVisual {
  final String terrainSprite;
  final String? contentSprite;
  final MapGlow glow;
  final bool dimmed;
  final bool revealed;
  final bool pending;

  /// Cells the content covers, per side: the volcano covers 2x2.
  final int contentSpan;

  /// Colour of the seal on a held volcano, null while it is free.
  final Color? sealColor;

  /// Colour of the faction whose base stands here, if the cell is seen.
  final Color? factionColor;

  /// Whether the content and its glow are drawn over the fog of a hidden
  /// cell: a wreck must be seen to be explored.
  final bool aboveFog;

  /// How the content and its glow idle. Anything but still is drawn by
  /// the ambience layer instead of the static map.
  final AmbientMotion motion;

  const MapCellVisual({
    required this.terrainSprite,
    this.contentSprite,
    this.glow = MapGlow.none,
    this.dimmed = false,
    this.revealed = false,
    this.pending = false,
    this.aboveFog = false,
    this.contentSpan = 1,
    this.sealColor,
    this.factionColor,
    this.motion = AmbientMotion.still,
  });

  factory MapCellVisual.from(
    MapCell cell, {
    required bool isRevealed,
    bool isBase = false,
    bool hasPendingExploration = false,
    PostHolder? postHolder,
    Color? factionColor,
    Color? sealColor,
  }) {
    final terrain = cell.terrain.svgPath;
    if (!isRevealed) {
      final beacon = _isBeacon(cell);
      return MapCellVisual(
        terrainSprite: terrain,
        contentSprite: beacon ? cell.content.svgPath : null,
        glow: beacon ? MapGlow.wreck : MapGlow.none,
        pending: hasPendingExploration,
        aboveFog: beacon,
        motion: beacon ? AmbientMotion.sway : AmbientMotion.still,
      );
    }
    final isHome = isBase || factionColor != null;
    final sprite =
        _contentSprite(cell, isHome, postHolder ?? PostHolder.guardians);
    final volcano = cell.content == CellContentType.volcanicKernel;
    // The volcano is never greyed out: its seal says who holds it.
    final dimmed = cell.collectedBy != null && !volcano;
    final motion = dimmed || sprite == null
        ? AmbientMotion.still
        : contentMotionOf(cell.content, isHome: isHome);
    return MapCellVisual(
      terrainSprite: terrain,
      contentSprite: sprite,
      factionColor: factionColor,
      glow: _isBeacon(cell) ? MapGlow.wreck : pulseGlowOf(cell.content, motion),
      dimmed: dimmed,
      motion: motion,
      contentSpan: volcano ? VolcanicKernelPlacer.side : 1,
      sealColor: volcano ? sealColor : null,
      revealed: true,
      pending: hasPendingExploration,
    );
  }

  static String? _contentSprite(MapCell cell, bool isBase, PostHolder holder) {
    final base = cell.transitionBase;
    if (cell.content == CellContentType.transitionBase && base != null) {
      return base.type.svgPathFor(holder);
    }
    if (cell.content == CellContentType.passage) {
      return passageSvgPath(cell.passageName, holder);
    }
    if (cell.content == CellContentType.transitionBase ||
        cell.content == CellContentType.volcanicKernelPart) {
      return null;
    }
    if (isBase) return playerBaseSvgPath;
    if (cell.content == CellContentType.monsterLair) return cell.lair?.svgPath;
    return cell.content.svgPath;
  }

  /// Content seen through the fog: a wreck not searched yet.
  static bool _isBeacon(MapCell cell) =>
      cell.content == CellContentType.wreck && !cell.isCollected;

  @override
  bool operator ==(Object other) =>
      other is MapCellVisual &&
      other.terrainSprite == terrainSprite &&
      other.contentSprite == contentSprite &&
      other.glow == glow &&
      other.dimmed == dimmed &&
      other.revealed == revealed &&
      other.pending == pending &&
      other.aboveFog == aboveFog &&
      other.contentSpan == contentSpan &&
      other.sealColor == sealColor &&
      other.factionColor == factionColor &&
      other.motion == motion;

  @override
  int get hashCode => Object.hash(terrainSprite, contentSprite, glow, dimmed,
      revealed, pending, aboveFog, contentSpan, sealColor, factionColor,
      motion);
}
