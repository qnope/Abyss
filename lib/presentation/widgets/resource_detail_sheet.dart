import 'package:flutter/material.dart';
import '../../domain/resource.dart';
import '../extensions/resource_type_extensions.dart';
import '../theme/abyss_colors.dart';
import 'resource_icon.dart';

void showResourceDetailSheet(BuildContext context, Resource resource, {required int production}) {
  showModalBottomSheet<void>(
    context: context,
    builder: (_) => _ResourceDetailSheet(resource: resource, production: production),
  );
}

class _ResourceDetailSheet extends StatelessWidget {
  final Resource resource;
  final int production;
  const _ResourceDetailSheet({required this.resource, required this.production});

  @override
  Widget build(BuildContext context) {
    final color = resource.type.color;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ResourceIcon(type: resource.type, size: 64),
          const SizedBox(height: 12),
          Text(resource.type.displayName, style: textTheme.headlineSmall?.copyWith(color: color)),
          const SizedBox(height: 8),
          Text(resource.type.flavorText, style: textTheme.bodyMedium?.copyWith(color: AbyssColors.onSurfaceDim), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text('${resource.amount} / ${resource.maxStorage}', style: textTheme.titleLarge?.copyWith(color: color)),
          const SizedBox(height: 16),
          if (production > 0) ...[
            Align(alignment: Alignment.centerLeft, child: Text('Production', style: textTheme.titleSmall?.copyWith(color: AbyssColors.onSurface))),
            const SizedBox(height: 8),
            _buildingRow('Bâtiment principal', production, color),
          ],
        ],
      ),
    );
  }

  Widget _buildingRow(String name, int amount, Color color) {
    return Row(
      children: [
        Icon(Icons.home, size: 16, color: AbyssColors.onSurfaceDim),
        const SizedBox(width: 8),
        Expanded(child: Text(name, style: TextStyle(color: AbyssColors.onSurfaceDim))),
        Text('+$amount/t', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
