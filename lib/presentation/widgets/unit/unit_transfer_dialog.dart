import 'package:flutter/material.dart';
import '../../../domain/unit/unit.dart';
import '../../../domain/unit/unit_type.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../fight/unit_quantity_row.dart';

/// Dialog picking how many units of each type in [availableUnits] to
/// move: a title, an optional [subtitle] and [notice], one row per type
/// in stock and a confirm button labelled with the total picked.
///
/// Confirming gives the non-zero picks to [onConfirm] then pops with
/// them; cancelling pops with `null`.
class UnitTransferDialog extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget? notice;
  final Map<UnitType, Unit> availableUnits;
  final String Function(int total) confirmLabel;
  final ValueChanged<Map<UnitType, int>>? onConfirm;

  const UnitTransferDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.notice,
    required this.availableUnits,
    required this.confirmLabel,
    this.onConfirm,
  });

  @override
  State<UnitTransferDialog> createState() => _UnitTransferDialogState();
}

class _UnitTransferDialogState extends State<UnitTransferDialog> {
  final Map<UnitType, int> _selected = {};

  int get _total => _selected.values.fold<int>(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stocked = widget.availableUnits.entries
        .where((e) => e.value.count > 0)
        .toList();
    return AlertDialog(
      title: _title(Theme.of(context).textTheme),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            if (widget.notice != null) ...[
              widget.notice!,
              const SizedBox(height: 12),
            ],
            if (stocked.isEmpty) Text(l10n.unitNoneAvailable),
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
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          onPressed: _total == 0 ? null : _confirm,
          child: Text(widget.confirmLabel(_total)),
        ),
      ],
    );
  }

  Widget _title(TextTheme textTheme) {
    final subtitle = widget.subtitle;
    if (subtitle == null) return Text(widget.title);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.title),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: textTheme.bodySmall?.copyWith(
            color: AbyssColors.onSurfaceDim,
          ),
        ),
      ],
    );
  }

  void _confirm() {
    final picks = <UnitType, int>{
      for (final e in _selected.entries)
        if (e.value > 0) e.key: e.value,
    };
    widget.onConfirm?.call(picks);
    Navigator.of(context).pop(picks);
  }
}
