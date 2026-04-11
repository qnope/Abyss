import 'package:flutter/material.dart';

import '../../../domain/map/transition_base.dart';
import '../../theme/abyss_colors.dart';
import 'transition_base_sheet.dart';

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
          _infoRow(textTheme, 'Difficulte',
              '${transitionBase.difficulty}/5'),
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

  Widget _infoRow(TextTheme t, String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: t.bodyMedium?.copyWith(
                color: AbyssColors.onSurfaceDim,
              )),
        ),
        Text(value,
            style: t.bodyMedium?.copyWith(
              color: AbyssColors.onSurface,
              fontWeight: FontWeight.bold,
            )),
      ],
    );
  }

}
