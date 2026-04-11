import 'package:flutter/material.dart';
import '../../../domain/map/game_map.dart';
import '../../../domain/map/grid_position.dart';
import '../../theme/abyss_colors.dart';
import 'map_cell_widget.dart';

class GameMapView extends StatefulWidget {
  final GameMap gameMap;
  final Set<GridPosition> revealedCells;
  final int? baseX;
  final int? baseY;
  final String humanPlayerId;
  final void Function(int x, int y)? onCellTap;
  final Set<(int, int)> pendingTargets;

  const GameMapView({
    super.key,
    required this.gameMap,
    required this.revealedCells,
    this.baseX,
    this.baseY,
    required this.humanPlayerId,
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
  static const _maxVisibleCells = 1.0;

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
    final centerX = widget.baseX ?? _mapSize ~/ 2;
    final centerY = widget.baseY ?? _mapSize ~/ 2;
    final basePixelX = centerX * cellSize;
    final basePixelY = centerY * cellSize;
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
        final pos = GridPosition(x: x, y: y);
        final isRevealed = widget.revealedCells.contains(pos);
        final isCollectedByOther = cell.collectedBy != null &&
            cell.collectedBy != widget.humanPlayerId;
        final isBase = x == widget.baseX && y == widget.baseY;
        final isCapturedTransitionBase =
            cell.transitionBase?.capturedBy == widget.humanPlayerId;
        return MapCellWidget(
          cell: cell,
          isRevealed: isRevealed,
          isCollectedByOther: isCollectedByOther,
          isBase: isBase,
          hasPendingExploration: widget.pendingTargets.contains((x, y)),
          isCapturedTransitionBase: isCapturedTransitionBase,
          onTap: widget.onCellTap != null
              ? () => widget.onCellTap!(x, y)
              : null,
        );
      }),
    );
  }
}
