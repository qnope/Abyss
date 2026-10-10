import 'package:flutter/material.dart';

import '../../../domain/resource/resource_type.dart';
import '../../extensions/resource_type_extensions.dart';
import 'resource_icon.dart';

/// Inline list of resource gains, each as its icon and « +N » in the
/// color of the resource. What is not gained is left out.
class ResourceGainsRow extends StatelessWidget {
  final Map<ResourceType, int> gains;

  const ResourceGainsRow({super.key, required this.gains});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        for (final MapEntry(:key, :value) in gains.entries)
          if (value > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ResourceIcon(type: key, size: 14),
                const SizedBox(width: 4),
                Text('+$value', style: style?.copyWith(color: key.color)),
              ],
            ),
      ],
    );
  }
}
