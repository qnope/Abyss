import '../../../domain/map/cell_content_type.dart';
import '../../../domain/map/map_cell.dart';
import '../../extensions/cell_content_type_extensions.dart';
import '../../extensions/terrain_type_extensions.dart';

const playerBaseSvgPath = 'assets/icons/map_content/player_base.svg';

/// Glowing marker drawn under a cell's content.
enum MapGlow { none, passage, capturedBase, hostileBase }

/// Everything needed to draw one map cell, decoupled from widgets so the
/// whole map can be painted in a single pass.
class MapCellVisual {
  final String terrainSprite;
  final String? contentSprite;
  final MapGlow glow;
  final bool dimmed;
  final bool revealed;
  final bool pending;

  const MapCellVisual({
    required this.terrainSprite,
    this.contentSprite,
    this.glow = MapGlow.none,
    this.dimmed = false,
    this.revealed = false,
    this.pending = false,
  });

  factory MapCellVisual.from(
    MapCell cell, {
    required bool isRevealed,
    bool isBase = false,
    bool hasPendingExploration = false,
    bool isCapturedTransitionBase = false,
  }) {
    final terrain = cell.terrain.svgPath;
    if (!isRevealed) {
      return MapCellVisual(
        terrainSprite: terrain,
        pending: hasPendingExploration,
      );
    }
    return MapCellVisual(
      terrainSprite: terrain,
      contentSprite: _contentSprite(cell, isBase),
      glow: _glow(cell, isCapturedTransitionBase),
      dimmed: cell.collectedBy != null,
      revealed: true,
      pending: hasPendingExploration,
    );
  }

  static String? _contentSprite(MapCell cell, bool isBase) {
    if (cell.content == CellContentType.passage ||
        cell.content == CellContentType.transitionBase) {
      return null;
    }
    if (isBase) return playerBaseSvgPath;
    if (cell.content == CellContentType.monsterLair) {
      return cell.lair?.difficulty.svgPath;
    }
    return cell.content.svgPath;
  }

  static MapGlow _glow(MapCell cell, bool isCaptured) {
    return switch (cell.content) {
      CellContentType.passage => MapGlow.passage,
      CellContentType.transitionBase =>
        isCaptured ? MapGlow.capturedBase : MapGlow.hostileBase,
      _ => MapGlow.none,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is MapCellVisual &&
      other.terrainSprite == terrainSprite &&
      other.contentSprite == contentSprite &&
      other.glow == glow &&
      other.dimmed == dimmed &&
      other.revealed == revealed &&
      other.pending == pending;

  @override
  int get hashCode => Object.hash(
        terrainSprite, contentSprite, glow, dimmed, revealed, pending);
}
