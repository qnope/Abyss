import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/abyss_colors.dart';

void showVolcanicKernelSheet(
  BuildContext context, {
  required bool isCaptured,
  required VoidCallback onAttack,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _VolcanicKernelSheet(
      isCaptured: isCaptured,
      onAttack: onAttack,
    ),
  );
}

class _VolcanicKernelSheet extends StatelessWidget {
  final bool isCaptured;
  final VoidCallback onAttack;

  const _VolcanicKernelSheet({
    required this.isCaptured,
    required this.onAttack,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/terrain/volcanic_kernel.svg',
            width: 64,
            height: 64,
          ),
          const SizedBox(height: 12),
          Text(
            'Noyau Volcanique',
            style: textTheme.headlineSmall?.copyWith(
              color: AbyssColors.biolumCyan,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isCaptured ? _capturedDescription : _uncapturedDescription,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AbyssColors.onSurfaceDim,
            ),
          ),
          const Divider(height: 24),
          if (!isCaptured)
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                onAttack();
              },
              child: const Text("Lancer l'assaut"),
            ),
        ],
      ),
    );
  }

  static const _uncapturedDescription =
      'Le coeur brulant des abysses est garde par de puissants gardiens.';

  static const _capturedDescription =
      'Vous avez capture le Noyau Volcanique. '
      'Construisez le batiment pour remporter la victoire.';
}
