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
    return AlertDialog(
      title: const Text('Resume du tour'),
      content: result.changes.isEmpty
          ? const Text('Aucun changement ce tour.')
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final change in result.changes)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        ResourceIcon(type: change.type),
                        const SizedBox(width: 8),
                        Text(change.type.displayName),
                        const Spacer(),
                        Text(
                          '+${change.produced}',
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
                  ),
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
}
