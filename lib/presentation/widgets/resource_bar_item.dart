import 'package:flutter/material.dart';
import '../../domain/resource.dart';
import '../extensions/resource_type_extensions.dart';
import '../theme/abyss_colors.dart';
import 'animated_resource_amount.dart';
import 'resource_icon.dart';

class ResourceBarItem extends StatelessWidget {
  final Resource resource;
  final int production;
  final int consumption;
  final VoidCallback? onTap;

  const ResourceBarItem({
    super.key,
    required this.resource,
    this.production = 0,
    this.consumption = 0,
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
          if (production > 0 || consumption > 0) ...[
            const SizedBox(width: 2),
            Text(
              _rateText,
              style: TextStyle(color: _rateColor(color), fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  String get _rateText {
    if (consumption > 0) return '+$production/-$consumption/t';
    return '+$production/t';
  }

  Color _rateColor(Color baseColor) {
    if (consumption > production) return AbyssColors.error;
    return baseColor.withValues(alpha: 0.7);
  }
}
