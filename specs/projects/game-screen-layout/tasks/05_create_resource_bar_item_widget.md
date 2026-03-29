# Task 05: Create ResourceBarItem widget

## Summary

Create a compact widget that displays a single resource: its icon, current amount, and production rate per turn. Each resource is color-coded using `AbyssColors`. The widget supports an `onTap` callback for opening the detail sheet.

## Implementation Steps

### Step 1: Create `lib/presentation/widgets/resource_bar_item.dart`

```dart
import 'package:flutter/material.dart';
import '../../domain/resource.dart';
import '../../domain/resource_type.dart';
import '../theme/abyss_colors.dart';
import 'resource_icon.dart';

class ResourceBarItem extends StatelessWidget {
  final Resource resource;
  final VoidCallback? onTap;

  const ResourceBarItem({
    super.key,
    required this.resource,
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
          Text(
            '${resource.amount}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (resource.productionPerTurn > 0) ...[
            const SizedBox(width: 2),
            Text(
              '+${resource.productionPerTurn}/t',
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
```

### Step 2: Add color extension on ResourceType

Add at the top of the same file (or as an extension):

```dart
extension ResourceTypeColor on ResourceType {
  Color get color => switch (this) {
    ResourceType.algae => AbyssColors.algaeGreen,
    ResourceType.coral => AbyssColors.coralPink,
    ResourceType.ore => AbyssColors.oreBlue,
    ResourceType.energy => AbyssColors.energyYellow,
    ResourceType.pearl => AbyssColors.pearlWhite,
  };
}
```

## Dependencies

- Task 01 (ResourceType in domain).
- Task 02 (Resource model).

## Test Plan

- **File:** `test/presentation/widgets/resource_bar_item_test.dart` (Task 12)
- Test: Renders icon, amount, and production rate.
- Test: Pearl shows no production rate.
- Test: onTap callback fires.

## Notes

- Production rate is hidden for resources with `productionPerTurn == 0` (Pearl).
- The `ResourceTypeColor` extension will also be used by other widgets (ResourceBar, ResourceDetailSheet).
- File should stay well under 150 lines.
