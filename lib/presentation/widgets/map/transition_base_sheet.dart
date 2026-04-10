import 'package:flutter/material.dart';

import '../../../domain/game/player.dart';
import '../../../domain/map/transition_base.dart';
import '../../extensions/transition_base_type_extensions.dart';
import '../../theme/abyss_colors.dart';
import 'transition_base_captured_section.dart';
import 'transition_base_uncaptured_section.dart';

void showTransitionBaseSheet(
  BuildContext context, {
  required TransitionBase transitionBase,
  required int level,
  required Player player,
  VoidCallback? onAttack,
  VoidCallback? onDescend,
  VoidCallback? onReinforce,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => transitionBase.isCaptured
        ? TransitionBaseCapturedSection(
            transitionBase: transitionBase,
            onDescend: onDescend,
            onReinforce: onReinforce,
          )
        : TransitionBaseUncapturedSection(
            transitionBase: transitionBase,
            player: player,
            onAttack: onAttack,
          ),
  );
}

class TransitionBaseHeader extends StatelessWidget {
  final TransitionBase transitionBase;

  const TransitionBaseHeader({super.key, required this.transitionBase});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Icon(Icons.waves, size: 48, color: transitionBase.type.glowColor),
        const SizedBox(height: 8),
        Text(
          transitionBase.name,
          style: textTheme.headlineSmall?.copyWith(
            color: AbyssColors.biolumCyan,
          ),
        ),
        Text(
          transitionBase.type.displayName,
          style: textTheme.bodySmall?.copyWith(
            color: AbyssColors.onSurfaceDim,
          ),
        ),
      ],
    );
  }
}
