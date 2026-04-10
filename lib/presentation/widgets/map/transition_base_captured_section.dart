import 'package:flutter/material.dart';

import '../../../domain/map/transition_base.dart';
import '../../theme/abyss_colors.dart';
import 'transition_base_sheet.dart';

class TransitionBaseCapturedSection extends StatelessWidget {
  final TransitionBase transitionBase;
  final VoidCallback? onDescend;
  final VoidCallback? onReinforce;

  const TransitionBaseCapturedSection({
    super.key,
    required this.transitionBase,
    this.onDescend,
    this.onReinforce,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TransitionBaseHeader(transitionBase: transitionBase),
          const SizedBox(height: 12),
          Text(
            'Capturee',
            style: textTheme.bodyMedium?.copyWith(
              color: AbyssColors.biolumCyan,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 24),
          FilledButton(
            onPressed: onDescend == null
                ? null
                : () {
                    Navigator.pop(context);
                    onDescend!();
                  },
            child: Text(
              'Descendre au Niveau ${transitionBase.targetLevel}',
            ),
          ),
          const SizedBox(height: 8),
          if (onReinforce != null)
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                onReinforce!();
              },
              child: const Text('Envoyer des renforts'),
            ),
        ],
      ),
    );
  }
}
