import 'package:flutter/material.dart';
import '../../domain/map_tile.dart';
import '../theme/abyss_colors.dart';

void showEnemyDetailSheet(
  BuildContext context, {
  required MapTile tile,
}) {
  showModalBottomSheet<void>(
    context: context,
    builder: (_) => _EnemyDetailSheet(tile: tile),
  );
}

class _EnemyDetailSheet extends StatelessWidget {
  final MapTile tile;

  const _EnemyDetailSheet({required this.tile});

  String get _factionName {
    final index = (tile.x * 7 + tile.y * 13) % _factionNames.length;
    return _factionNames[index];
  }

  static const _factionNames = [
    'Faction Abyssale',
    'Clan des Profondeurs',
    'Horde du Récif',
    'Légion Corallienne',
    'Empire des Courants',
    'Ordre de l\'Abîme',
    'Confrérie des Marées',
    'Alliance des Failles',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield, size: 48, color: AbyssColors.biolumPurple),
          const SizedBox(height: 12),
          Text(_factionName,
            style: textTheme.headlineSmall?.copyWith(
              color: AbyssColors.biolumPurple)),
          const SizedBox(height: 4),
          Text('(${tile.x}, ${tile.y})',
            style: textTheme.bodySmall?.copyWith(
              color: AbyssColors.onSurfaceDim)),
          const SizedBox(height: 8),
          _buildStatusChip(textTheme),
          const SizedBox(height: 12),
          Text(
            'Une faction rivale a établi sa base ici. '
            'Ses intentions restent inconnues.',
            style: textTheme.bodyMedium?.copyWith(
              color: AbyssColors.onSurfaceDim),
            textAlign: TextAlign.center,
          ),
          const Divider(height: 24),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildStatusChip(TextTheme textTheme) {
    return Chip(
      avatar: Icon(Icons.handshake, size: 16, color: AbyssColors.onSurface),
      label: Text('Neutre',
        style: textTheme.bodySmall?.copyWith(color: AbyssColors.onSurface)),
      backgroundColor: AbyssColors.surfaceBright,
      side: BorderSide.none,
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _actionButton(Icons.swords, 'Attaquer'),
        _actionButton(Icons.handshake, 'Diplomatie'),
        _actionButton(Icons.visibility, 'Espionner'),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: null,
          icon: Icon(icon, color: AbyssColors.disabled),
        ),
        Text(label,
          style: const TextStyle(
            fontSize: 11,
            color: AbyssColors.disabled)),
      ],
    );
  }
}
