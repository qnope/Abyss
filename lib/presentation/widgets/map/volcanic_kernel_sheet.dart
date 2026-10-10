import 'package:flutter/material.dart';
import '../../../domain/game/player.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../common/raster_svg.dart';
import '../volcano/kernel_garrison_panel.dart';

/// [player] is the human player; the garrison panel only shows once the
/// kernel is captured.
void showVolcanicKernelSheet(
  BuildContext context, {
  required bool isCaptured,
  required Player player,
  required VoidCallback onAttack,
  required VoidCallback onGarrison,
  required VoidCallback onWithdraw,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _VolcanicKernelSheet(
      isCaptured: isCaptured,
      player: player,
      onAttack: onAttack,
      onGarrison: onGarrison,
      onWithdraw: onWithdraw,
    ),
  );
}

class _VolcanicKernelSheet extends StatelessWidget {
  final bool isCaptured;
  final Player player;
  final VoidCallback onAttack;
  final VoidCallback onGarrison;
  final VoidCallback onWithdraw;

  const _VolcanicKernelSheet({
    required this.isCaptured,
    required this.player,
    required this.onAttack,
    required this.onGarrison,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RasterSvg(
            assetPath: 'assets/icons/terrain/volcanic_kernel.svg',
            size: 64,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.buildingVolcanicKernelName,
            style: textTheme.headlineSmall?.copyWith(
              color: AbyssColors.biolumCyan,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isCaptured ? l10n.mapKernelCaptured : l10n.mapKernelUncaptured,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AbyssColors.onSurfaceDim,
            ),
          ),
          const Divider(height: 24),
          if (isCaptured)
            KernelGarrisonPanel(
              player: player,
              onGarrison: () => _closeThen(context, onGarrison),
              onWithdraw: () => _closeThen(context, onWithdraw),
            )
          else
            FilledButton(
              onPressed: () => _closeThen(context, onAttack),
              child: Text(l10n.fightLaunchAssault),
            ),
        ],
      ),
    );
  }

  static void _closeThen(BuildContext context, VoidCallback action) {
    Navigator.pop(context);
    action();
  }
}
