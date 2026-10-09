import 'package:flutter/material.dart';
import '../../../domain/unit/unit.dart';
import '../../../domain/unit/unit_type.dart';
import '../../theme/abyss_colors.dart';
import '../fight/unit_quantity_row.dart';

/// Dialog that picks how many units of each type to move, out of
/// [availableUnits]. Returns the non-zero picks, or `null` when cancelled.
Future<Map<UnitType, int>?> showUnitPickerDialog(
  BuildContext context, {
  required String title,
  required Map<UnitType, Unit> availableUnits,
  required String confirmLabel,
  String? info,
}) =>
    showDialog<Map<UnitType, int>>(
      context: context,
      builder: (_) => _UnitPickerDialog(
        title: title,
        availableUnits: availableUnits,
        confirmLabel: confirmLabel,
        info: info,
      ),
    );

class _UnitPickerDialog extends StatefulWidget {
  final String title;
  final Map<UnitType, Unit> availableUnits;
  final String confirmLabel;
  final String? info;

  const _UnitPickerDialog({
    required this.title,
    required this.availableUnits,
    required this.confirmLabel,
    this.info,
  });

  @override
  State<_UnitPickerDialog> createState() => _UnitPickerDialogState();
}

class _UnitPickerDialogState extends State<_UnitPickerDialog> {
  final Map<UnitType, int> _selected = {};

  int get _total => _selected.values.fold<int>(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final stocked = widget.availableUnits.entries
        .where((e) => e.value.count > 0)
        .toList();
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            if (widget.info != null) ...[
              Text(
                widget.info!,
                style: textTheme.bodySmall?.copyWith(
                  color: AbyssColors.onSurfaceDim,
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (stocked.isEmpty) const Text('Aucune unité disponible.'),
            for (final e in stocked)
              UnitQuantityRow(
                type: e.key,
                stock: e.value.count,
                value: _selected[e.key] ?? 0,
                onChanged: (v) => setState(() => _selected[e.key] = v),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _total == 0
              ? null
              : () => Navigator.of(context).pop(<UnitType, int>{
                    for (final e in _selected.entries)
                      if (e.value > 0) e.key: e.value,
                  }),
          child: Text('${widget.confirmLabel} ($_total)'),
        ),
      ],
    );
  }
}
