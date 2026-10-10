import '../../../domain/map/cell_content_type.dart';
import '../../../domain/map/map_cell.dart';
import '../../extensions/cell_content_type_extensions.dart';
import '../../extensions/monster_lair_extensions.dart';
import '../../extensions/terrain_type_extensions.dart';

const playerBaseSvgPath = 'assets/icons/map_content/player_base.svg';

/// Glowing marker drawn under a cell's content.
enum MapGlow { none, passage, capturedBase, hostileBase, wreck }

/// Everything needed to draw one map cell, decoupled from widgets so the
/// whole map can be painted in a single pass.
class MapCellVisual {
  final String terrainSprite;
  final String? contentSprite;
  final MapGlow glow;
  final bool dimmed;
  final bool revealed;
  final bool pending;

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
      return cell.lair?.svgPath;
    }
    return cell.content.svgPath;
  }

  /// Content seen through the fog: a wreck not searched yet.
  static bool _isBeacon(MapCell cell) =>
      cell.content == CellContentType.wreck && !cell.isCollected;

  static MapGlow _glow(MapCell cell, bool isCaptured) {
    if (_isBeacon(cell)) return MapGlow.wreck;
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
      other.pending == pending &&
      other.aboveFog == aboveFog;

  @override
  int get hashCode => Object.hash(terrainSprite, contentSprite, glow, dimmed,
        revealed, pending, aboveFog);
}
