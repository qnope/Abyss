import 'package:flutter/material.dart';
import '../../../domain/resource/resource.dart';
import '../../../domain/resource/resource_type.dart';
import '../../theme/abyss_colors.dart';
import 'resource_bar_item.dart';
import 'resource_detail_sheet.dart';

class ResourceBar extends StatelessWidget {
  final Map<ResourceType, Resource> resources;
  final Map<ResourceType, int> production;
  final Map<ResourceType, int> consumption;

  const ResourceBar({
    super.key,
    required this.resources,
    this.production = const {},
    this.consumption = const {},
  });

  @override
  Widget build(BuildContext context) {
    final productionResources = resources.entries
        .where((e) => e.key != ResourceType.pearl)
        .map((e) => e.value)
        .toList();
    final pearl = resources[ResourceType.pearl]!;

    return Container(
      color: AbyssColors.abyssBlack.withValues(alpha: 0.9),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              ...productionResources.map((r) => Expanded(
                child: Center(
                  child: ResourceBarItem(
                    resource: r,
                    production: production[r.type] ?? 0,
                    consumption: consumption[r.type] ?? 0,
                    onTap: () => _showDetail(context, r),
                  ),
                ),
              )),
              Container(
                width: 1,
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: AbyssColors.onSurfaceDim.withValues(alpha: 0.3),
              ),
              ResourceBarItem(
                resource: pearl,
                production: production[ResourceType.pearl] ?? 0,
                consumption: consumption[ResourceType.pearl] ?? 0,
                onTap: () => _showDetail(context, pearl),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, Resource resource) {
    showResourceDetailSheet(
      context,
      resource,
      production: production[resource.type] ?? 0,
    );
  }
}
