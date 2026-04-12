import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../domain/game/game_statistics.dart';
import '../../theme/abyss_colors.dart';

class VictoryScreen extends StatelessWidget {
  final GameStatistics statistics;
  final VoidCallback onContinue;
  final VoidCallback onReturnToMenu;

  const VictoryScreen({
    super.key,
    required this.statistics,
    required this.onContinue,
    required this.onReturnToMenu,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/terrain/volcanic_kernel.svg',
                width: 96,
                height: 96,
              ),
              const SizedBox(height: 16),
              Text(
                'VICTOIRE !',
                style: textTheme.displayMedium?.copyWith(
                  color: AbyssColors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vous avez conquis le Noyau Volcanique !',
                style: textTheme.bodyLarge?.copyWith(
                  color: AbyssColors.onSurfaceDim,
                ),
                textAlign: TextAlign.center,
              ),
              const Divider(height: 32),
              _StatisticsCard(statistics: statistics),
              const SizedBox(height: 32),
              _ActionButtons(
                onContinue: onContinue,
                onReturnToMenu: onReturnToMenu,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatisticsCard extends StatelessWidget {
  final GameStatistics statistics;

  const _StatisticsCard({required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _StatRow(
              icon: Icons.timer,
              label: 'Tours joues: ${statistics.turnsPlayed}',
            ),
            _StatRow(
              icon: Icons.dangerous,
              label: 'Monstres vaincus: ${statistics.monstersDefeated}',
            ),
            _StatRow(
              icon: Icons.flag,
              label: 'Bases capturees: ${statistics.basesCaptured}',
            ),
            _StatRow(
              icon: Icons.inventory,
              label: 'Ressources collectees: '
                  '${statistics.totalResourcesCollected}',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AbyssColors.biolumCyan),
            const SizedBox(width: 12),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onReturnToMenu;

  const _ActionButtons({
    required this.onContinue,
    required this.onReturnToMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContinue,
            child: const Text('Continuer en mode libre'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onReturnToMenu,
            child: const Text('Retour au menu'),
          ),
        ),
      ],
    );
  }
}
