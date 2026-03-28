import 'package:flutter/material.dart';
import '../../domain/game.dart';
import '../theme/abyss_colors.dart';

class SavedGameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onLoad;
  final VoidCallback onDelete;

  const SavedGameCard({
    super.key,
    required this.game,
    required this.onLoad,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: onLoad,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 16),
              Expanded(child: _buildInfo(textTheme)),
              _buildDeleteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AbyssColors.biolumCyan.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.waves,
        color: AbyssColors.biolumCyan,
      ),
    );
  }

  Widget _buildInfo(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          game.player.name,
          style: textTheme.titleMedium?.copyWith(
            color: AbyssColors.biolumCyan,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tour ${game.turn}',
          style: textTheme.bodyMedium?.copyWith(
            color: AbyssColors.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _formatDate(game.createdAt),
          style: textTheme.bodySmall?.copyWith(
            color: AbyssColors.onSurfaceDim,
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return IconButton(
      onPressed: onDelete,
      icon: const Icon(Icons.delete_outline),
      color: AbyssColors.error,
      tooltip: 'Supprimer',
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}
