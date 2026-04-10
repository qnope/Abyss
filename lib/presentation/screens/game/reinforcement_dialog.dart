import 'package:flutter/material.dart';
import '../../../domain/unit/unit.dart';
import '../../../domain/unit/unit_type.dart';
import '../../theme/abyss_colors.dart';
import '../../widgets/fight/unit_quantity_row.dart';

class ReinforcementDialog extends StatefulWidget {
  final Map<UnitType, Unit> availableUnits;
  final int targetLevel;
  final String transitionBaseName;
  final void Function(Map<UnitType, int> selectedUnits) onConfirm;

  const ReinforcementDialog({
    super.key,
    required this.availableUnits,
    required this.targetLevel,
    required this.transitionBaseName,
    required this.onConfirm,
  });

  @override
  State<ReinforcementDialog> createState() => _ReinforcementDialogState();
}

class _ReinforcementDialogState extends State<ReinforcementDialog> {
  final Map<UnitType, int> _selected = {};

  @override
  void initState() {
    super.initState();
    for (final type in widget.availableUnits.keys) {
      _selected[type] = 0;
    }
  }

  int get _totalSelected =>
      _selected.values.fold<int>(0, (sum, v) => sum + v);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      title: _buildTitle(textTheme),
      content: SizedBox(
        width: double.maxFinite,
        child: _buildContent(textTheme),
      ),
      actions: _buildActions(),
    );
  }

  Widget _buildTitle(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Renforts vers Niveau ${widget.targetLevel}'),
        const SizedBox(height: 4),
        Text(
          widget.transitionBaseName,
          style: textTheme.bodySmall?.copyWith(
            color: AbyssColors.onSurfaceDim,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(TextTheme textTheme) {
    return ListView(
      shrinkWrap: true,
      children: [
        _buildInfoBanner(textTheme),
        const SizedBox(height: 12),
        ..._buildUnitRows(),
      ],
    );
  }

  Widget _buildInfoBanner(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AbyssColors.biolumBlue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AbyssColors.biolumBlue.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AbyssColors.biolumBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Les renforts arriveront au prochain tour.',
              style: textTheme.bodySmall?.copyWith(
                color: AbyssColors.biolumBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildUnitRows() {
    final rows = <Widget>[];
    for (final entry in widget.availableUnits.entries) {
      final stock = entry.value.count;
      if (stock <= 0) continue;
      rows.add(UnitQuantityRow(
        type: entry.key,
        stock: stock,
        value: _selected[entry.key] ?? 0,
        onChanged: (v) => setState(() => _selected[entry.key] = v),
      ));
    }
    return rows;
  }

  List<Widget> _buildActions() {
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Annuler'),
      ),
      ElevatedButton(
        onPressed: _totalSelected == 0 ? null : _onConfirm,
        child: Text('Envoyer ($_totalSelected unites)'),
      ),
    ];
  }

  void _onConfirm() {
    final nonZero = <UnitType, int>{
      for (final e in _selected.entries)
        if (e.value > 0) e.key: e.value,
    };
    widget.onConfirm(nonZero);
    Navigator.of(context).pop();
  }
}
