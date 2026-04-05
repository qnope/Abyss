import 'package:flutter/material.dart';
import '../../domain/game_map.dart';
import '../../domain/map_tile.dart';
import '../theme/abyss_colors.dart';
import 'map_tile_widget.dart';

class GameMapView extends StatelessWidget {
  final GameMap gameMap;
  final ValueChanged<MapTile> onTileTap;

  static const double _tileSize = 48;

  const GameMapView({
    super.key,
    required this.gameMap,
    required this.onTileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AbyssColors.abyssBlack,
      child: InteractiveViewer(
        constrained: false,
        minScale: 0.5,
        maxScale: 2.0,
        child: SizedBox(
          width: gameMap.width * _tileSize,
          height: gameMap.height * _tileSize,
          child: _buildGrid(),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return Column(
      children: [
        for (int y = 0; y < gameMap.height; y++)
          Row(
            children: [
              for (int x = 0; x < gameMap.width; x++)
                SizedBox(
                  width: _tileSize,
                  height: _tileSize,
                  child: MapTileWidget(
                    tile: gameMap.tileAt(x, y),
                    onTap: () => onTileTap(gameMap.tileAt(x, y)),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
