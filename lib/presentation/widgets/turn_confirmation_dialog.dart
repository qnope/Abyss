import 'package:flutter/material.dart';
import '../../domain/resource.dart';
import '../../domain/resource_type.dart';
import '../extensions/resource_type_extensions.dart';
import '../theme/abyss_colors.dart';
import 'resource_icon.dart';

Future<bool> showTurnConfirmationDialog(
  BuildContext context, {
  required int currentTurn,
  required Map<ResourceType, Resource> resources,
  required Map<ResourceType, int> netProduction,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => _TurnConfirmationDialog(
      currentTurn: currentTurn,
      resources: resources,
      netProduction: netProduction,
    ),
  );
  return result ?? false;
}

class _TurnConfirmationDialog extends StatelessWidget {
  final int currentTurn;
  final Map<ResourceType, Resource> resources;
  final Map<ResourceType, int> netProduction;

  const _TurnConfirmationDialog({
    required this.currentTurn,
    required this.resources,
    required this.netProduction,
  });

  @override
  Widget build(BuildContext context) {
    // Show all producible resources (exclude pearl)
    final types = ResourceType.values.where((t) => t != ResourceType.pearl);
    return AlertDialog(
      title: Text('Tour $currentTurn \u2192 Tour ${currentTurn + 1}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final type in types)
            _buildResourceLine(type),
        ],
      ),
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

  Widget _buildResourceLine(ResourceType type) {
    final resource = resources[type];
    if (resource == null) return const SizedBox.shrink();
    final net = netProduction[type] ?? 0;
    final predicted = (resource.amount + net).clamp(0, resource.maxStorage);
    final isCapped = resource.amount + net > resource.maxStorage;
    final isNegative = net < 0;
    final sign = net >= 0 ? '+' : '';
    final netColor = isNegative
        ? AbyssColors.error
        : (net == 0 ? AbyssColors.onSurfaceDim : type.color);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          ResourceIcon(type: type),
          const SizedBox(width: 8),
          Text(type.displayName),
          const Spacer(),
          Text(
            '${resource.amount} ($sign$net) \u2192 $predicted',
            style: TextStyle(color: isCapped ? AbyssColors.warning : netColor),
          ),
          if (isCapped) ...[
            const SizedBox(width: 4),
            const Text('(MAX)', style: TextStyle(color: AbyssColors.warning)),
          ],
        ],
      ),
    );
  }
}
