import 'package:flutter/painting.dart';

import '../../../domain/map/cell_content_type.dart';
import '../../../domain/map/map_cell.dart';
import '../../../domain/map/post_holder.dart';
import '../../../domain/map/volcanic_kernel_placer.dart';
import '../../extensions/cell_content_type_extensions.dart';
import '../../extensions/monster_lair_extensions.dart';
import '../../extensions/post_holder_extensions.dart';
import '../../extensions/terrain_type_extensions.dart';

const playerBaseSvgPath = 'assets/icons/map_content/player_base.svg';
const volcanoSealSvgPath = 'assets/icons/terrain/volcanic_kernel_seal.svg';

/// Glowing marker drawn under a cell's content.
enum MapGlow { none, wreck }

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
      );
    }
    return MapCellVisual(
      terrainSprite: terrain,
      contentSprite: _contentSprite(
          cell, isBase || factionColor != null, postHolder ?? PostHolder.guardians),
      factionColor: factionColor,
      glow: _isBeacon(cell) ? MapGlow.wreck : MapGlow.none,
      // The volcano is never greyed out: its seal says who holds it.
      dimmed: cell.collectedBy != null &&
          cell.content != CellContentType.volcanicKernel,
      contentSpan: cell.content == CellContentType.volcanicKernel
          ? VolcanicKernelPlacer.side
          : 1,
      sealColor: cell.content == CellContentType.volcanicKernel
          ? sealColor
          : null,
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
    if (cell.content == CellContentType.monsterLair) {
      return cell.lair?.svgPath;
    }
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
      other.factionColor == factionColor;

  @override
  int get hashCode => Object.hash(terrainSprite, contentSprite, glow, dimmed,
        revealed, pending, aboveFog, contentSpan, sealColor, factionColor);
}
