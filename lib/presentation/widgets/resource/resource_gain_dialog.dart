import 'package:flutter/material.dart';
import '../../../domain/resource/resource_type.dart';
import '../../extensions/resource_type_extensions.dart';
import '../../theme/abyss_colors.dart';
import 'resource_icon.dart';

Future<void> showResourceGainDialog(
  BuildContext context, {
  required String title,
  required Map<ResourceType, int> deltas,
  String emptyMessage = 'Rien a recuperer ici...',
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ResourceGainDialog(
      title: title,
      deltas: deltas,
      emptyMessage: emptyMessage,
    ),
  );
}

class _ResourceGainDialog extends StatelessWidget {
  final String title;
  final Map<ResourceType, int> deltas;
  final String emptyMessage;

  const _ResourceGainDialog({
    required this.title,
    required this.deltas,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final entries = _nonZeroEntries();
    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(color: AbyssColors.biolumCyan),
      ),
      content: entries.isEmpty
          ? Text(emptyMessage)
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in entries) _buildResourceLine(entry),
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

  List<MapEntry<ResourceType, int>> _nonZeroEntries() {
    final result = <MapEntry<ResourceType, int>>[];
    for (final type in ResourceType.values) {
      final value = deltas[type] ?? 0;
      if (value > 0) {
        result.add(MapEntry(type, value));
      }
    }
    return result;
  }

  Widget _buildResourceLine(MapEntry<ResourceType, int> entry) {
    final type = entry.key;
    final amount = entry.value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          ResourceIcon(type: type),
          const SizedBox(width: 8),
          Text(type.displayName),
          const Spacer(),
          Text(
            '+$amount',
            style: TextStyle(color: type.color),
          ),
        ],
      ),
    );
  }
}
