import 'package:flutter/material.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/resource/resource_type.dart';
import '../../../domain/unit/unit_type.dart';
import '../../extensions/resource_type_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../resource/resource_icon.dart';
import 'turn_loss_sections.dart';

Future<bool> showTurnConfirmationDialog(
  BuildContext context, {
  required int currentTurn,
  required Map<ResourceType, int> production,
  Map<ResourceType, int> consumption = const {},
  List<BuildingType> buildingsToDeactivate = const [],
  Map<UnitType, int> unitsToLose = const {},
  int pendingExplorationCount = 0,
  Widget? raidWarning,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => _TurnConfirmationDialog(
      currentTurn: currentTurn,
      production: production,
      consumption: consumption,
      buildingsToDeactivate: buildingsToDeactivate,
      unitsToLose: unitsToLose,
      pendingExplorationCount: pendingExplorationCount,
      raidWarning: raidWarning,
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
  final int pendingExplorationCount;
  final Widget? raidWarning;

  const _TurnConfirmationDialog({
    required this.currentTurn,
    required this.production,
    required this.consumption,
    required this.buildingsToDeactivate,
    required this.unitsToLose,
    required this.pendingExplorationCount,
    this.raidWarning,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tour $currentTurn \u2192 Tour ${currentTurn + 1}'),
      content: _buildContent(context),
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

  Widget _buildContent(BuildContext context) {
    final hasProduction = production.isNotEmpty;
    final hasWarnings = buildingsToDeactivate.isNotEmpty;
    final hasLosses = unitsToLose.isNotEmpty;

    if (!hasProduction && !hasWarnings && !hasLosses &&
        raidWarning == null) {
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
                Text(entry.key.displayName(context.l10n)),
                const Spacer(),
                Text(
                  '+${entry.value}',
                  style: TextStyle(color: entry.key.color),
                ),
              ],
            ),
          ),
        if (pendingExplorationCount > 0) ..._buildExplorationSection(),
        if (hasWarnings)
          DeactivatedBuildingsSection(buildings: buildingsToDeactivate),
        if (hasLosses) LostUnitsSection(units: unitsToLose),
        if (raidWarning != null) raidWarning!,
      ],
    );
  }

  List<Widget> _buildExplorationSection() => [
        const Divider(),
        Row(children: [
          Icon(Icons.explore, color: AbyssColors.biolumCyan),
          const SizedBox(width: 8),
          Text(
            '$pendingExplorationCount exploration'
            '${pendingExplorationCount > 1 ? 's' : ''} en attente',
            style: TextStyle(color: AbyssColors.biolumCyan),
          ),
        ]),
      ];
}
