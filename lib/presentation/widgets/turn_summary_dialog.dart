import 'package:flutter/material.dart';
import '../../domain/turn_result.dart';
import '../extensions/building_type_extensions.dart';
import '../extensions/resource_type_extensions.dart';
import '../extensions/unit_type_extensions.dart';
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
    return AlertDialog(
      title: Text(
        'Tour ${result.previousTurn} \u2192 Tour ${result.newTurn}',
      ),
      content: _buildContent(),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final hasChanges = result.changes.isNotEmpty;
    final hasWarnings = result.deactivatedBuildings.isNotEmpty;
    final hasLosses = result.lostUnits.isNotEmpty;
    final showArmy = result.hadRecruitedUnits;

    if (!hasChanges && !hasWarnings && !hasLosses && !showArmy) {
      return const Text('Aucun changement ce tour.');
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final change in result.changes)
          _buildResourceLine(change),
        if (hasWarnings) ..._buildBuildingWarnings(),
        if (hasLosses) ..._buildUnitLosses(),
        if (showArmy) ...[
          if (hasChanges || hasWarnings || hasLosses) const Divider(),
          _buildArmySection(),
        ],
      ],
    );
  }

  Widget _buildResourceLine(TurnResourceChange change) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          ResourceIcon(type: change.type),
          const SizedBox(width: 8),
          Text(change.type.displayName),
          const Spacer(),
          Text(
            _formatChange(change),
            style: TextStyle(color: change.type.color),
          ),
          if (change.wasCapped) ...[
            const SizedBox(width: 4),
            Text(
              '(max atteint)',
              style: TextStyle(color: AbyssColors.warning),
            ),
          ],
        ],
      ),
    );
  }

  String _formatChange(TurnResourceChange change) {
    if (change.consumed > 0) {
      return '+${change.produced}/-${change.consumed}';
    }
    return '+${change.produced}';
  }

  List<Widget> _buildBuildingWarnings() => [
        const Divider(),
        Row(children: [
          Icon(Icons.warning, color: AbyssColors.warning),
          const SizedBox(width: 8),
          Text('Batiments desactives',
              style: TextStyle(color: AbyssColors.warning)),
        ]),
        for (final building in result.deactivatedBuildings)
          Text(building.displayName,
              style: TextStyle(color: AbyssColors.warning)),
      ];

  List<Widget> _buildUnitLosses() => [
        const Divider(),
        Row(children: [
          Icon(Icons.error, color: AbyssColors.error),
          const SizedBox(width: 8),
          Text('Unites perdues',
              style: TextStyle(color: AbyssColors.error)),
        ]),
        for (final entry in result.lostUnits.entries)
          Text('${entry.key.displayName}: -${entry.value}',
              style: TextStyle(color: AbyssColors.error)),
      ];

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
