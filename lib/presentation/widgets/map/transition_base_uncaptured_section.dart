import 'package:flutter/material.dart';

import '../../../domain/map/transition_base.dart';
import '../../theme/abyss_colors.dart';
import 'transition_base_sheet.dart';
import 'sheet_info_row.dart';

class TransitionBaseUncapturedSection extends StatelessWidget {
  final TransitionBase transitionBase;
  final VoidCallback? onAttack;

  const TransitionBaseUncapturedSection({
    super.key,
    required this.transitionBase,
    this.onAttack,
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
          const SizedBox(height: 8),
          SheetInfoRow('Difficulte',
              '${transitionBase.difficulty}/5'),
          const SizedBox(height: 6),
          SheetInfoRow('Revenu une fois capturee',
              '+${transitionBase.pearlsPerTurn} perles / tour'),
          const SizedBox(height: 6),
          Text(
            'Neutre \u2014 Gardiens presents',
            style: textTheme.bodyMedium?.copyWith(
              color: AbyssColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 24),
          FilledButton(
            onPressed: onAttack != null
                ? () {
                    Navigator.pop(context);
                    onAttack!();
                  }
                : null,
            child: const Text('Assaut'),
          ),
        ],
      ),
    );
  }
}
