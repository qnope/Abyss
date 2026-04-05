import 'package:flutter/material.dart';
import '../../domain/game_map.dart';
import '../theme/abyss_colors.dart';
import 'map_cell_widget.dart';

class GameMapView extends StatefulWidget {
  final GameMap gameMap;

  const GameMapView({super.key, required this.gameMap});

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
        return MapCellWidget(cell: cell, isBase: isBase);
      }),
    );
  }
}
