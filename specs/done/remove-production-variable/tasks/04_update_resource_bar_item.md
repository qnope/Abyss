# Task 04 — Update ResourceBarItem to accept production parameter

## Summary

Replace `resource.productionPerTurn` reads in `ResourceBarItem` with an explicit `int production` constructor parameter.

## Implementation Steps

### Step 1: Edit `lib/presentation/widgets/resource_bar_item.dart`

Add `production` field:

```dart
class ResourceBarItem extends StatelessWidget {
  final Resource resource;
  final int production;           // ADD
  final VoidCallback? onTap;

  const ResourceBarItem({
    super.key,
    required this.resource,
    this.production = 0,          // ADD
    this.onTap,
  });
```

Replace in `build()`:

```dart
// BEFORE:
if (resource.productionPerTurn > 0) ...[
  ...
  '+${resource.productionPerTurn}/t',

// AFTER:
if (production > 0) ...[
  ...
  '+$production/t',
```

## Dependencies

- Task 02 (productionPerTurn removed from Resource)

## Test Plan

- Widget tests updated in Task 08.
