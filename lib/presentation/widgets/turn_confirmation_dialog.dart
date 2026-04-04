import 'package:flutter/material.dart';
import '../../domain/resource_type.dart';
import '../extensions/resource_type_extensions.dart';
import 'resource_icon.dart';

Future<bool> showTurnConfirmationDialog(
  BuildContext context, {
  required Map<ResourceType, int> production,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => _TurnConfirmationDialog(production: production),
  );
  return result ?? false;
}

class _TurnConfirmationDialog extends StatelessWidget {
  final Map<ResourceType, int> production;

  const _TurnConfirmationDialog({required this.production});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Passer au tour suivant ?'),
      content: production.isEmpty
          ? const Text('Aucune production ce tour.')
          : Column(
              mainAxisSize: MainAxisSize.min,
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
}
