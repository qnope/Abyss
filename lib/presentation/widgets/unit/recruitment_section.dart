import 'package:flutter/material.dart';

import '../../../domain/raid/noise_rules.dart';
import '../../../domain/resource/resource_type.dart';
import '../../../domain/unit/unit_cost_calculator.dart';
import '../../../domain/unit/unit_type.dart';
import '../../extensions/resource_type_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../raid/noise_cost_row.dart';
import '../resource/resource_icon.dart';

class RecruitmentSection extends StatefulWidget {
  final UnitType unitType;
  final int maxRecruitableCount;
  final bool hasRecruitedThisType;
  final void Function(int quantity) onRecruit;

  const RecruitmentSection({
    super.key,
    required this.unitType,
    required this.maxRecruitableCount,
    required this.hasRecruitedThisType,
    required this.onRecruit,
  });

  @override
  State<RecruitmentSection> createState() => _RecruitmentSectionState();
}

class _RecruitmentSectionState extends State<RecruitmentSection> {
  int _sliderValue = 0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    if (widget.hasRecruitedThisType) {
      return Text(
        l10n.unitRecruitDone,
        style: textTheme.bodyMedium?.copyWith(color: AbyssColors.warning),
      );
    }

    if (widget.maxRecruitableCount == 0) {
      return Text(
        l10n.unitNotEnoughResources,
        style: textTheme.bodyMedium?.copyWith(color: AbyssColors.disabled),
      );
    }

    final costs = UnitCostCalculator().recruitmentCost(widget.unitType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Slider(
          min: 0,
          max: widget.maxRecruitableCount.toDouble(),
          divisions: widget.maxRecruitableCount,
          value: _sliderValue.toDouble(),
          onChanged: (value) => setState(() => _sliderValue = value.round()),
        ),
        Text(l10n.unitTotalCount(_sliderValue), style: textTheme.bodyMedium),
        const SizedBox(height: 8),
        ...costs.entries.map((e) => _costRow(e.key, e.value, textTheme)),
        NoiseCostRow(noise: NoiseRules.perRecruit * _sliderValue),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _sliderValue > 0
              ? () => widget.onRecruit(_sliderValue)
              : null,
          child: Text(l10n.unitRecruit),
        ),
      ],
    );
  }

  Widget _costRow(ResourceType type, int unitCost, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          ResourceIcon(type: type, size: 16),
          const SizedBox(width: 8),
          Text(
            '${unitCost * _sliderValue}',
            style: TextStyle(color: type.color),
          ),
        ],
      ),
    );
  }
}
