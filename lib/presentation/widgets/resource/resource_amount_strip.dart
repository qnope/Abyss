import 'package:flutter/material.dart';

import '../../../domain/resource/resource_type.dart';
import '../../theme/abyss_colors.dart';
import 'resource_icon.dart';

/// Compact line of resource icons, each followed by its amount, wrapping
/// onto a new line rather than overflowing a narrow box.
class ResourceAmountStrip extends StatelessWidget {
  final Map<ResourceType, int> amounts;
  final double iconSize;

  const ResourceAmountStrip({
    super.key,
    required this.amounts,
    this.iconSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: AbyssColors.onSurface,
    );
    return Wrap(
      spacing: 10,
      runSpacing: 2,
      children: [
        for (final MapEntry(:key, :value) in amounts.entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ResourceIcon(type: key, size: iconSize),
              const SizedBox(width: 3),
              Text('$value', style: style),
            ],
          ),
      ],
    );
  }
}
