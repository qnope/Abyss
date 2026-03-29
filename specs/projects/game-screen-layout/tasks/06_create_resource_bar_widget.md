# Task 06: Create ResourceBar widget

## Summary

Create a horizontal bar that displays all 5 resources, replacing the current AppBar. Pearl is visually separated from the 4 production resources. Tapping a resource opens its detail sheet.

## Implementation Steps

### Step 1: Create `lib/presentation/widgets/resource_bar.dart`

```dart
import 'package:flutter/material.dart';
import '../../domain/resource.dart';
import '../../domain/resource_type.dart';
import '../theme/abyss_colors.dart';
import 'resource_bar_item.dart';
import 'resource_detail_sheet.dart';

class ResourceBar extends StatelessWidget {
  final List<Resource> resources;

  const ResourceBar({super.key, required this.resources});

  @override
  Widget build(BuildContext context) {
    final production = resources.where((r) => r.type != ResourceType.pearl).toList();
    final pearl = resources.firstWhere((r) => r.type == ResourceType.pearl);

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
```

### Key Design Decisions

- Production resources (algae, coral, ore, energy) use `Expanded` for even spacing.
- A vertical divider separates Pearl from production resources (per US-1).
- `SafeArea` only applies to top (notch/status bar), not bottom.
- Background matches the old AppBar color for consistency.

## Dependencies

- Task 05 (ResourceBarItem widget).
- Task 07 (ResourceDetailSheet — for the `showResourceDetailSheet` function).

## Test Plan

- **File:** `test/presentation/widgets/resource_bar_test.dart` (Task 12)
- Test: Renders all 5 resources.
- Test: Pearl is visually separated (divider exists).
- Test: Tapping a resource triggers the bottom sheet.

## Notes

- The bar replaces the AppBar entirely — GameScreen's Scaffold will have no AppBar.
- File should stay well under 150 lines.
