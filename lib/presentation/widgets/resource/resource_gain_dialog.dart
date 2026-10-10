import 'package:flutter/material.dart';
import '../../../domain/resource/resource_type.dart';
import '../../extensions/resource_type_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import 'resource_icon.dart';

Future<void> showResourceGainDialog(
  BuildContext context, {
  required String title,
  required Map<ResourceType, int> deltas,
  String? emptyMessage,
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
  /// What the dialog says when nothing was found; "Rien à récupérer ici..."
  /// by default.
  final String? emptyMessage;

  const _ResourceGainDialog({
    required this.title,
    required this.deltas,
    this.emptyMessage,
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
          ? Text(emptyMessage ?? context.l10n.screenNothingToCollect)
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in entries) _buildResourceLine(context, entry),
              ],
            ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.commonOk),
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

  Widget _buildResourceLine(
    BuildContext context,
    MapEntry<ResourceType, int> entry,
  ) {
    final type = entry.key;
    final amount = entry.value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          ResourceIcon(type: type),
          const SizedBox(width: 8),
          Text(type.displayName(context.l10n)),
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
