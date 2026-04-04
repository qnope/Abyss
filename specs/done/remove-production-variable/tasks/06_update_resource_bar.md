# Task 06 — Update ResourceBar to accept and pass production map

## Summary

Add a `Map<ResourceType, int> production` parameter to `ResourceBar`. Pass individual production values to each `ResourceBarItem` and to `showResourceDetailSheet`.

## Implementation Steps

### Step 1: Edit `lib/presentation/widgets/resource_bar.dart`

Add field and constructor param:

```dart
class ResourceBar extends StatelessWidget {
  final Map<ResourceType, Resource> resources;
  final Map<ResourceType, int> production;    // ADD

  const ResourceBar({
    super.key,
    required this.resources,
    this.production = const {},                // ADD
  });
```

Pass production to `ResourceBarItem`:

```dart
// In the map for production resources:
child: ResourceBarItem(
  resource: r,
  production: production[r.type] ?? 0,    // ADD
  onTap: () => _showDetail(context, r),
),

// For pearl:
ResourceBarItem(
  resource: pearl,
  production: production[ResourceType.pearl] ?? 0,   // ADD
  onTap: () => _showDetail(context, pearl),
),
```

Pass production to detail sheet:

```dart
void _showDetail(BuildContext context, Resource resource) {
  showResourceDetailSheet(
    context,
    resource,
    production: production[resource.type] ?? 0,    // ADD
  );
}
```

## Dependencies

- Task 04 (ResourceBarItem accepts `production`)
- Task 05 (showResourceDetailSheet accepts `production`)
