# Task 05 — Update ResourceDetailSheet to accept production parameter

## Summary

Replace `resource.productionPerTurn` reads in `ResourceDetailSheet` and `showResourceDetailSheet` with an explicit `int production` parameter.

## Implementation Steps

### Step 1: Edit `lib/presentation/widgets/resource_detail_sheet.dart`

Update top-level function signature:

```dart
// BEFORE:
void showResourceDetailSheet(BuildContext context, Resource resource) {

// AFTER:
void showResourceDetailSheet(BuildContext context, Resource resource, {required int production}) {
```

Pass production to the private widget:

```dart
builder: (_) => _ResourceDetailSheet(resource: resource, production: production),
```

Update private widget:

```dart
class _ResourceDetailSheet extends StatelessWidget {
  final Resource resource;
  final int production;           // ADD
  const _ResourceDetailSheet({required this.resource, required this.production});
```

Replace in `build()`:

```dart
// BEFORE:
if (resource.productionPerTurn > 0) ...[
  ...
  _buildingRow('Batiment principal', resource.productionPerTurn, color),

// AFTER:
if (production > 0) ...[
  ...
  _buildingRow('Batiment principal', production, color),
```

## Dependencies

- Task 02 (productionPerTurn removed from Resource)
