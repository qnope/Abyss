import 'package:flutter/material.dart';
import '../../../domain/map/game_map.dart';
import '../../../domain/map/map_cell.dart';
import '../../theme/abyss_colors.dart';
import 'map_cell_widget.dart';

class GameMapView extends StatefulWidget {
  final GameMap gameMap;
  final void Function(int x, int y)? onCellTap;
  final Set<(int, int)> pendingTargets;

  const GameMapView({
    super.key,
    required this.gameMap,
    this.onCellTap,
    this.pendingTargets = const {},
  });

  @override
  State<GameMapView> createState() => _GameMapViewState();
}

class _GameMapViewState extends State<GameMapView> {
  late final TransformationController _controller;

  static const _mapSize = 20;
  static const _gridSize = _mapSize * cellSize;
  static const _defaultVisibleCells = 8.0;
  static const _maxVisibleCells = 4.0;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerOnBase();
    });
  }

  void _centerOnBase() {
    final size = MediaQuery.of(context).size;
    final scale = size.width / (_defaultVisibleCells * cellSize);
    final basePixelX = widget.gameMap.playerBaseX * cellSize;
    final basePixelY = widget.gameMap.playerBaseY * cellSize;
    final dx = size.width / 2 - (basePixelX + cellSize / 2) * scale;
    final dy = size.height / 2 - (basePixelY + cellSize / 2) * scale;
    _controller.value = Matrix4(
      scale, 0, 0, 0,
      0, scale, 0, 0,
      0, 0, 1, 0,
      dx, dy, 0, 1,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final minScale = screenWidth / _gridSize;
    final maxScale = screenWidth / (_maxVisibleCells * cellSize);

    return InteractiveViewer(
      constrained: false,
      transformationController: _controller,
      minScale: minScale,
      maxScale: maxScale,
      child: Container(
        color: AbyssColors.abyssBlack,
        width: _gridSize,
        height: _gridSize,
        child: Column(
          children: List.generate(_mapSize, (y) => _buildRow(y)),
        ),
      ),
    );
  }

  Row _buildRow(int y) {
    return Row(
      children: List.generate(_mapSize, (x) {
        final cell = widget.gameMap.cellAt(x, y);
        final isBase = x == widget.gameMap.playerBaseX &&
            y == widget.gameMap.playerBaseY;
        return _CachedMapCellWrapper(
          key: ValueKey('$x:$y'),
          cell: cell,
          isBase: isBase,
          hasPendingExploration: widget.pendingTargets.contains((x, y)),
          x: x,
          y: y,
          onCellTap: widget.onCellTap,
        );
      }),
    );
  }
}

class _CachedMapCellWrapper extends StatelessWidget {
  final MapCell cell;
  final bool isBase;
  final bool hasPendingExploration;
  final int x;
  final int y;
  final void Function(int, int)? onCellTap;

  const _CachedMapCellWrapper({
    super.key,
    required this.cell,
    required this.isBase,
    required this.hasPendingExploration,
    required this.x,
    required this.y,
    this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return MapCellWidget(
      cell: cell,
      isBase: isBase,
      hasPendingExploration: hasPendingExploration,
      onTap: onCellTap != null ? () => onCellTap!(x, y) : null,
    );
  }
}
