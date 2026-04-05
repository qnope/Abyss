import 'package:flutter/material.dart';

import '../../../domain/resource/resource.dart';
import '../../../domain/resource/resource_type.dart';
import '../../../domain/unit/unit_cost_calculator.dart';
import '../../../domain/unit/unit_stats.dart';
import '../../../domain/unit/unit_type.dart';
import '../../extensions/unit_type_extensions.dart';
import '../../theme/abyss_colors.dart';
import 'recruitment_section.dart';
import 'unit_icon.dart';

void showUnitDetailSheet(
  BuildContext context, {
  required UnitType unitType,
  required int count,
  required bool isUnlocked,
  required int barracksLevel,
  required Map<ResourceType, Resource> resources,
  required bool hasRecruitedThisType,
  required void Function(int quantity) onRecruit,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _UnitDetailSheet(
      unitType: unitType,
      count: count,
      isUnlocked: isUnlocked,
      barracksLevel: barracksLevel,
      resources: resources,
      hasRecruitedThisType: hasRecruitedThisType,
      onRecruit: onRecruit,
    ),
  );
}

class _UnitDetailSheet extends StatelessWidget {
  final UnitType unitType;
  final int count;
  final bool isUnlocked;
  final int barracksLevel;
  final Map<ResourceType, Resource> resources;
  final bool hasRecruitedThisType;
  final void Function(int quantity) onRecruit;

  const _UnitDetailSheet({
    required this.unitType,
    required this.count,
    required this.isUnlocked,
    required this.barracksLevel,
    required this.resources,
    required this.hasRecruitedThisType,
    required this.onRecruit,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UnitIcon(type: unitType, size: 64),
          const SizedBox(height: 12),
          Text(
            unitType.displayName,
            style: textTheme.headlineSmall?.copyWith(color: unitType.color),
          ),
          const SizedBox(height: 4),
          Text(unitType.role, style: textTheme.bodySmall),
          if (!isUnlocked) ..._lockedContent(textTheme),
          if (isUnlocked) ..._unlockedContent(textTheme),
        ],
      ),
    );
  }

  List<Widget> _lockedContent(TextTheme textTheme) {
    final level = UnitCostCalculator().unlockLevel(unitType);
    return [
      const SizedBox(height: 16),
      Text(
        'Caserne niveau $level requise pour debloquer',
        style: textTheme.bodyMedium?.copyWith(color: AbyssColors.disabled),
      ),
    ];
  }

  List<Widget> _unlockedContent(TextTheme textTheme) {
    final stats = UnitStats.forType(unitType);
    final maxCount = UnitCostCalculator().maxRecruitableCount(
      unitType,
      barracksLevel,
      resources,
    );

    return [
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Chip(label: Text('PV: ${stats.hp}')),
          const SizedBox(width: 8),
          Chip(label: Text('ATQ: ${stats.atk}')),
          const SizedBox(width: 8),
          Chip(label: Text('DEF: ${stats.def}')),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        'En service: $count',
        style: textTheme.bodyMedium?.copyWith(
          color: AbyssColors.onSurfaceDim,
        ),
      ),
      const Divider(height: 24),
      RecruitmentSection(
        unitType: unitType,
        maxRecruitableCount: maxCount,
        hasRecruitedThisType: hasRecruitedThisType,
        onRecruit: onRecruit,
      ),
    ];
  }
}
