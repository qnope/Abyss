import 'package:flutter/material.dart';

import '../../../domain/building/building_type.dart';
import '../../../domain/game/player.dart';
import '../../../domain/map/transition_base.dart';
import '../../../domain/map/transition_base_type.dart';
import '../../theme/abyss_colors.dart';
import 'transition_base_sheet.dart';

class TransitionBaseUncapturedSection extends StatelessWidget {
  final TransitionBase transitionBase;
  final Player player;
  final VoidCallback? onAttack;

  const TransitionBaseUncapturedSection({
    super.key,
    required this.transitionBase,
    required this.player,
    this.onAttack,
  });

  bool get _prerequisiteMet {
    final type = transitionBase.type == TransitionBaseType.faille
        ? BuildingType.descentModule
        : BuildingType.pressureCapsule;
    return (player.buildings[type]?.level ?? 0) >= 1;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isFaille = transitionBase.type == TransitionBaseType.faille;
    final prereqLabel = isFaille
        ? 'Module de Descente construit'
        : 'Capsule Pressurisee construite';

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
          const SizedBox(height: 12),
          _prerequisiteRow(textTheme, prereqLabel, _prerequisiteMet),
          const Divider(height: 24),
          FilledButton(
            onPressed: _prerequisiteMet && onAttack != null
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

  Widget _prerequisiteRow(TextTheme t, String label, bool met) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_box : Icons.check_box_outline_blank,
          size: 20,
          color: met ? AbyssColors.success : AbyssColors.onSurfaceDim,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: t.bodyMedium?.copyWith(
                color: met ? AbyssColors.success : AbyssColors.onSurfaceDim,
              )),
        ),
      ],
    );
  }
}
