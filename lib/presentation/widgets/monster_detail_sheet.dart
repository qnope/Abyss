import 'package:flutter/material.dart';
import '../../domain/map_tile.dart';
import '../../domain/tile_content.dart';
import '../extensions/tile_content_extensions.dart';
import '../theme/abyss_colors.dart';

void showMonsterDetailSheet(
  BuildContext context, {
  required MapTile tile,
}) {
  showModalBottomSheet<void>(
    context: context,
    builder: (_) => _MonsterDetailSheet(tile: tile),
  );
}

class _MonsterDetailSheet extends StatelessWidget {
  final MapTile tile;

  const _MonsterDetailSheet({required this.tile});

  int get _level => switch (tile.content) {
    TileContent.monsterLevel1 => 1,
    TileContent.monsterLevel2 => 2,
    TileContent.monsterLevel3 => 3,
    _ => 0,
  };

  String get _description => switch (tile.content) {
    TileContent.monsterLevel1 =>
      'Un petit groupe de créatures marines. Peu menaçant.',
    TileContent.monsterLevel2 =>
      'Un nid de prédateurs sous-marins. Approchez avec prudence.',
    TileContent.monsterLevel3 =>
      'Un léviathan ancien garde cette zone. '
      'Seule une armée aguerrie survivrait.',
    _ => '',
  };

  String get _strength => switch (tile.content) {
    TileContent.monsterLevel1 => 'Faible',
    TileContent.monsterLevel2 => 'Modéré',
    TileContent.monsterLevel3 => 'Dangereux',
    _ => '',
  };

  String get _loot => switch (tile.content) {
    TileContent.monsterLevel1 => '50-100 Algues, 30-50 Corail',
    TileContent.monsterLevel2 => '100-200 Corail, 50-100 Minerai, 1-2 Perles',
    TileContent.monsterLevel3 =>
      '200-300 Minerai, 100-200 Énergie, 3-5 Perles',
    _ => '',
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = tile.content.iconColor;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pest_control, size: 48, color: color),
          const SizedBox(height: 12),
          Text('Créature de niveau $_level',
            style: textTheme.headlineSmall?.copyWith(color: color)),
          const SizedBox(height: 4),
          Text('(${tile.x}, ${tile.y})',
            style: textTheme.bodySmall?.copyWith(
              color: AbyssColors.onSurfaceDim)),
          const SizedBox(height: 8),
          Text(_description,
            style: textTheme.bodyMedium?.copyWith(
              color: AbyssColors.onSurfaceDim),
            textAlign: TextAlign.center),
          const Divider(height: 24),
          _buildInfoRow(textTheme, 'Puissance', _strength, color),
          const SizedBox(height: 8),
          _buildInfoRow(textTheme, 'Butin potentiel', _loot, null),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.swords),
            label: const Text('Attaquer'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    TextTheme textTheme,
    String label,
    String value,
    Color? valueColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label : ',
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(value,
            style: textTheme.bodyMedium?.copyWith(
              color: valueColor ?? AbyssColors.onSurface)),
        ),
      ],
    );
  }
}
