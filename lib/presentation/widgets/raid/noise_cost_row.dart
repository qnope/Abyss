import 'package:flutter/material.dart';

import '../../theme/abyss_colors.dart';

/// "+N bruit" line shown under an action's cost, so the player sees how
/// much the action fills the raid gauge.
class NoiseCostRow extends StatelessWidget {
  final int noise;

  const NoiseCostRow({super.key, required this.noise});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.graphic_eq, size: 16, color: AbyssColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Bruit',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            '+$noise',
            style: const TextStyle(color: AbyssColors.warning),
          ),
        ],
      ),
    );
  }
}
