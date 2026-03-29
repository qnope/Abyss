import 'package:flutter/material.dart';
import '../../domain/resource.dart';
import '../../domain/resource_type.dart';
import '../theme/abyss_colors.dart';
import 'resource_bar_item.dart';
import 'resource_detail_sheet.dart';

class ResourceBar extends StatelessWidget {
  final Map<ResourceType, Resource> resources;

  const ResourceBar({super.key, required this.resources});

  @override
  Widget build(BuildContext context) {
    final production = resources.entries
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
              ...production.map((r) => Expanded(
                child: Center(
                  child: ResourceBarItem(
                    resource: r,
                    onTap: () => _showDetail(context, r),
                  ),
                ),
              )),
              Container(
                width: 1,
                height: 24,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: AbyssColors.onSurfaceDim.withValues(alpha: 0.3),
              ),
              ResourceBarItem(
                resource: pearl,
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
    showResourceDetailSheet(context, resource);
  }
}
