import 'package:flutter/material.dart';
import '../../../domain/resource/resource.dart';
import '../../../domain/resource/resource_type.dart';
import '../../theme/abyss_colors.dart';
import '../resource/resource_icon.dart';

/// Inline list of resource costs, each shown in red when the player
/// cannot afford it.
class TechCostRow extends StatelessWidget {
  final Map<ResourceType, int> costs;
  final Map<ResourceType, Resource> resources;

  const TechCostRow({super.key, required this.costs, required this.resources});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge;
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        for (final e in costs.entries)
          Row(mainAxisSize: MainAxisSize.min, children: [
            ResourceIcon(type: e.key, size: 16),
            const SizedBox(width: 4),
            Text('${e.value}',
              style: style?.copyWith(
                color: (resources[e.key]?.amount ?? 0) >= e.value
                    ? AbyssColors.onSurface
                    : AbyssColors.error)),
          ]),
      ],
    );
  }
}
