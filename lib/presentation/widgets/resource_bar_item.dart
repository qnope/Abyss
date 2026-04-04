import 'package:flutter/material.dart';
import '../../domain/resource.dart';
import '../extensions/resource_type_extensions.dart';
import 'animated_resource_amount.dart';
import 'resource_icon.dart';

class ResourceBarItem extends StatelessWidget {
  final Resource resource;
  final int production;
  final VoidCallback? onTap;

  const ResourceBarItem({
    super.key,
    required this.resource,
    this.production = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = resource.type.color;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ResourceIcon(type: resource.type, size: 20),
          const SizedBox(width: 4),
          AnimatedResourceAmount(
            amount: resource.amount,
            baseColor: color,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (production > 0) ...[
            const SizedBox(width: 2),
            Text(
              '+$production/t',
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
