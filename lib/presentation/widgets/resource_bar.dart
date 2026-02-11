import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:abysses/core/constants/game_constants.dart';

class ResourceBar extends ConsumerWidget {
  const ResourceBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: const Color(0xFF0D1F3C),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildResource(Icons.monetization_on, 'Crédits', GameConstants.initialCredits, 60, const Color(0xFFFFD54F)),
          _buildResource(Icons.grass, 'Bio', GameConstants.initialBiomass, 100, const Color(0xFF81C784)),
          _buildResource(Icons.diamond, 'Min', GameConstants.initialMinerals, 80, const Color(0xFF90CAF9)),
          _buildResource(Icons.bolt, 'Énergie', GameConstants.initialEnergy, 120, const Color(0xFFFFAB40)),
        ],
      ),
    );
  }

  Widget _buildResource(IconData icon, String label, int amount, int rate, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              _formatNumber(amount),
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        Text(
          '+$rate/h',
          style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 10),
        ),
      ],
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}
