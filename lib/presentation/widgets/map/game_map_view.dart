import 'package:flutter/material.dart';
import '../../../domain/map/game_map.dart';
import '../../../domain/map/grid_position.dart';
import '../../../domain/map/post_holder.dart';
import 'map_cell_visual.dart';
import 'map_layers.dart';
import 'map_painter.dart';
import 'map_sprites.dart';
import 'map_viewport.dart';
import 'map_visuals_builder.dart';

class GameMapView extends StatefulWidget {
  final GameMap gameMap;
  final Set<GridPosition> revealedCells;
  final int? baseX;
  final int? baseY;
  final String humanPlayerId;
  final void Function(int x, int y)? onCellTap;
  final Set<(int, int)> pendingTargets;

  /// Colour of the faction base standing on each cell, level 1 only.
  final Map<GridPosition, Color> factionBases;

  /// Seal colour of each player who can hold the volcano, by player id.
  final Map<String, Color> ownerColors;

  /// Who holds the post above each passage of [gameMap], by position.
  final Map<GridPosition, PostHolder> passageHolders;

  /// Level of [gameMap], where the guide's halo may surround a cell.
  final int level;

  const GameMapView({
    super.key,
    required this.gameMap,
    required this.revealedCells,
    this.baseX,
    this.baseY,
    required this.humanPlayerId,
    this.onCellTap,
    this.pendingTargets = const {},
    this.factionBases = const {},
    this.ownerColors = const {},
    this.passageHolders = const {},
    this.level = 1,
  });

  @override
  State<GameMapView> createState() => _GameMapViewState();
}

class _GameMapViewState extends State<GameMapView> {
  final _controller = TransformationController();
  MapSprites? _sprites;

  static const _defaultVisibleCells = 8.0;
  static const _maxVisibleCells = 1.0;

  @override
  void initState() {
    super.initState();
    _sprites = MapSprites.ready;
    if (_sprites == null) _loadSprites();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Centered before the first frame, so the map never shows a jump.
    if (_controller.value.isIdentity()) _centerOnBase();
  }

  void _loadSprites() {
    MapSprites.load().then(
      (sprites) {
        if (mounted) setState(() => _sprites = sprites);
      },
      onError: (Object error) => debugPrint('Map sprites failed: $error'),
    );
  }

  void _centerOnBase() {
    final size = MediaQuery.of(context).size;
    final scale = size.width / (_defaultVisibleCells * cellSize);
    final centerX = widget.baseX ?? widget.gameMap.width ~/ 2;
    final centerY = widget.baseY ?? widget.gameMap.height ~/ 2;
    final basePixelX = centerX * cellSize;
    final basePixelY = centerY * cellSize;
    final dx = size.width / 2 - (basePixelX + cellSize / 2) * scale;
    final dy = size.height / 2 - (basePixelY + cellSize / 2) * scale;
    _controller.value = Matrix4.translationValues(dx, dy, 0)
      ..scaleByDouble(scale, scale, 1, 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final map = widget.gameMap;
    final gridSize = Size(map.width * cellSize, map.height * cellSize);
    final screenWidth = MediaQuery.of(context).size.width;
    final minScale = screenWidth / gridSize.width;
    final maxScale = screenWidth / (_maxVisibleCells * cellSize);

    return MapViewport(
      controller: _controller,
      minScale: minScale,
      maxScale: maxScale,
      onTapUp: widget.onCellTap == null ? null : _handleTap,
      builder: (context, clock, viewport) => MapLayers(
        visuals: _visuals(),
        columns: map.width,
        sprites: _sprites,
        clock: clock,
        transform: _controller,
        viewport: viewport,
        level: widget.level,
      ),
    );
  }

  List<MapCellVisual> _visuals() => buildMapVisuals(
        gameMap: widget.gameMap,
        revealedCells: widget.revealedCells,
        humanPlayerId: widget.humanPlayerId,
        baseX: widget.baseX,
        baseY: widget.baseY,
        pendingTargets: widget.pendingTargets,
        factionBases: widget.factionBases,
        ownerColors: widget.ownerColors,
        passageHolders: widget.passageHolders,
      );

  void _handleTap(TapUpDetails details) {
    final x = details.localPosition.dx ~/ cellSize;
    final y = details.localPosition.dy ~/ cellSize;
    final map = widget.gameMap;
    if (x < 0 || y < 0 || x >= map.width || y >= map.height) return;
    widget.onCellTap!(x, y);
  }
}
