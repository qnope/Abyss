import 'package:flutter/material.dart';
import '../../domain/map_tile.dart';
import '../../domain/tile_content.dart';
import '../extensions/terrain_type_extensions.dart';
import '../theme/abyss_colors.dart';

void showTileDetailSheet(BuildContext context, {required MapTile tile}) {
  showModalBottomSheet<void>(
    context: context,
    builder: (_) => _TileDetailSheet(tile: tile),
  );
}

class _TileDetailSheet extends StatelessWidget {
  final MapTile tile;

  const _TileDetailSheet({required this.tile});

  @override
  Widget build(BuildContext context) {
    if (!tile.revealed) return _buildHidden(context);
    if (tile.content == TileContent.playerBase) {
      return _buildBase(context);
    }
    return _buildEmpty(context);
  }

  Widget _buildHidden(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.visibility_off, size: 48, color: AbyssColors.disabled),
          const SizedBox(height: 12),
          Text('Zone inexplorée', style: textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('(${tile.x}, ${tile.y})',
            style: textTheme.bodySmall?.copyWith(
              color: AbyssColors.onSurfaceDim)),
          const SizedBox(height: 8),
          Text(
            'Les profondeurs restent un mystère. '
            'Envoyez des éclaireurs pour révéler cette zone.',
            style: textTheme.bodyMedium?.copyWith(
              color: AbyssColors.onSurfaceDim),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.explore),
            label: const Text('Explorer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.water, size: 48, color: tile.terrain.color),
          const SizedBox(height: 12),
          Text(tile.terrain.displayName, style: textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('(${tile.x}, ${tile.y})',
            style: textTheme.bodySmall?.copyWith(
              color: AbyssColors.onSurfaceDim)),
          const SizedBox(height: 8),
          Text(
            tile.terrain.description,
            style: textTheme.bodyMedium?.copyWith(
              color: AbyssColors.onSurfaceDim),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBase(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.home, size: 48, color: AbyssColors.biolumCyan),
          const SizedBox(height: 12),
          Text('Votre base', style: textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('(${tile.x}, ${tile.y})',
            style: textTheme.bodySmall?.copyWith(
              color: AbyssColors.onSurfaceDim)),
          const SizedBox(height: 8),
          Text(
            'Le coeur de votre colonie sous-marine.',
            style: textTheme.bodyMedium?.copyWith(
              color: AbyssColors.onSurfaceDim),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
