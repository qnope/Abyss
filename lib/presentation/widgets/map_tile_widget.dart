import 'package:flutter/material.dart';
import '../../domain/map_tile.dart';
import '../../domain/tile_content.dart';
import '../extensions/terrain_type_extensions.dart';
import '../extensions/tile_content_extensions.dart';
import '../theme/abyss_colors.dart';

class MapTileWidget extends StatelessWidget {
  final MapTile tile;
  final VoidCallback onTap;

  const MapTileWidget({
    super.key,
    required this.tile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: tile.revealed ? tile.terrain.color : AbyssColors.abyssBlack,
          border: Border.all(
            color: AbyssColors.deepNavy,
            width: 0.5,
          ),
        ),
        child: tile.revealed ? _buildContent() : _buildHidden(),
      ),
    );
  }

  Widget _buildHidden() {
    return Center(
      child: Icon(
        Icons.question_mark,
        size: 10,
        color: AbyssColors.disabled.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildContent() {
    final icon = tile.content.icon;
    if (icon == null) return const SizedBox.shrink();
    return Center(
      child: _buildIcon(icon),
    );
  }

  Widget _buildIcon(IconData icon) {
    if (tile.content == TileContent.playerBase) {
      return _buildBaseIcon(icon);
    }
    return Icon(
      icon,
      size: tile.content.iconSize,
      color: tile.content.iconColor,
    );
  }

  Widget _buildBaseIcon(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AbyssColors.biolumCyan.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(icon, size: 22, color: AbyssColors.biolumCyan),
    );
  }
}
