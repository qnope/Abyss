import 'package:flutter/material.dart';
import '../../domain/turn_result.dart';
import '../extensions/resource_type_extensions.dart';
import '../theme/abyss_colors.dart';
import 'resource_icon.dart';

Future<void> showTurnSummaryDialog(
  BuildContext context, {
  required TurnResult result,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => _TurnSummaryDialog(result: result),
  );
}

class _TurnSummaryDialog extends StatelessWidget {
  final TurnResult result;

  const _TurnSummaryDialog({required this.result});

  @override
  Widget build(BuildContext context) {
    final hasChanges = result.changes.isNotEmpty;
    final showArmy = result.hadRecruitedUnits;
    return AlertDialog(
      title: Text('Tour ${result.previousTurn} → Tour ${result.newTurn}'),
      content: !hasChanges && !showArmy
          ? const Text('Aucun changement ce tour.')
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final change in result.changes)
                  _buildResourceLine(change),
                if (showArmy) ...[
                  if (hasChanges) const Divider(),
                  _buildArmySection(),
                ],
              ],
            ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _buildResourceLine(TurnResourceChange change) {
    final sign = change.produced >= 0 ? '+' : '';
    final isNegative = change.produced < 0;
    final netColor = isNegative
        ? AbyssColors.error
        : (change.produced == 0
            ? AbyssColors.onSurfaceDim
            : change.type.color);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          ResourceIcon(type: change.type),
          const SizedBox(width: 8),
          Text(change.type.displayName),
          const Spacer(),
          Text(
            '${change.beforeAmount} ($sign${change.produced})'
            ' → ${change.afterAmount}',
            style: TextStyle(
              color: change.wasCapped ? AbyssColors.warning : netColor,
            ),
          ),
          if (change.wasCapped) ...[
            const SizedBox(width: 4),
            const Text(
              '(MAX)',
              style: TextStyle(color: AbyssColors.warning),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildArmySection() {
    return const Row(
      children: [
        Icon(Icons.shield, color: AbyssColors.success, size: 20),
        SizedBox(width: 8),
        Text(
          'Recrutement disponible',
          style: TextStyle(color: AbyssColors.success),
        ),
      ],
    );
  }
}
