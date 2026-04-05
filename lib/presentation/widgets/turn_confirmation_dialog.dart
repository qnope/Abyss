import 'package:flutter/material.dart';
import '../../domain/building_type.dart';
import '../../domain/resource_type.dart';
import '../../domain/unit_type.dart';
import '../extensions/building_type_extensions.dart';
import '../extensions/resource_type_extensions.dart';
import '../extensions/unit_type_extensions.dart';
import '../theme/abyss_colors.dart';
import 'resource_icon.dart';

Future<bool> showTurnConfirmationDialog(
  BuildContext context, {
  required int currentTurn,
  required Map<ResourceType, int> production,
  Map<ResourceType, int> consumption = const {},
  List<BuildingType> buildingsToDeactivate = const [],
  Map<UnitType, int> unitsToLose = const {},
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => _TurnConfirmationDialog(
      currentTurn: currentTurn,
      production: production,
      consumption: consumption,
      buildingsToDeactivate: buildingsToDeactivate,
      unitsToLose: unitsToLose,
    ),
  );
  return result ?? false;
}

class _TurnConfirmationDialog extends StatelessWidget {
  final int currentTurn;
  final Map<ResourceType, int> production;
  final Map<ResourceType, int> consumption;
  final List<BuildingType> buildingsToDeactivate;
  final Map<UnitType, int> unitsToLose;

  const _TurnConfirmationDialog({
    required this.currentTurn,
    required this.production,
    required this.consumption,
    required this.buildingsToDeactivate,
    required this.unitsToLose,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tour $currentTurn \u2192 Tour ${currentTurn + 1}'),
      content: _buildContent(),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Confirmer'),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final hasProduction = production.isNotEmpty;
    final hasWarnings = buildingsToDeactivate.isNotEmpty;
    final hasLosses = unitsToLose.isNotEmpty;

    if (!hasProduction && !hasWarnings && !hasLosses) {
      return const Text('Aucune production ce tour.');
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in production.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                ResourceIcon(type: entry.key),
                const SizedBox(width: 8),
                Text(entry.key.displayName),
                const Spacer(),
                Text(
                  '+${entry.value}',
                  style: TextStyle(color: entry.key.color),
                ),
              ],
            ),
          ),
        if (hasWarnings) ..._buildBuildingWarnings(),
        if (hasLosses) ..._buildUnitLosses(),
      ],
    );
  }

  List<Widget> _buildBuildingWarnings() => [
        const Divider(),
        Row(children: [
          Icon(Icons.warning, color: AbyssColors.warning),
          const SizedBox(width: 8),
          Text('Batiments desactives',
              style: TextStyle(color: AbyssColors.warning)),
        ]),
        for (final building in buildingsToDeactivate)
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
        for (final entry in unitsToLose.entries)
          Text('${entry.key.displayName}: -${entry.value}',
              style: TextStyle(color: AbyssColors.error)),
      ];
}
