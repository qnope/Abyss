# Task 11: Update ResourceBar for Consumption Display

## Summary

Update `ResourceBarItem` and `ResourceBar` to show `+X / -Y` format for energy and algae, with alert color when consumption exceeds production.

## Implementation Steps

### 1. Update `lib/presentation/widgets/resource_bar_item.dart`

Add a `consumption` parameter:
```dart
class ResourceBarItem extends StatelessWidget {
  final Resource resource;
  final int production;
  final int consumption;  // NEW — default 0
  final VoidCallback? onTap;
```

Update production display logic:
- If `consumption > 0`: show `+$production/-$consumption/t` instead of `+$production/t`
- If `consumption > production`: use `AbyssColors.error` color for the text (alert)
- If `consumption <= production` and `consumption > 0`: use normal resource color
- If `consumption == 0`: keep existing behavior (`+$production/t`)

### 2. Update `lib/presentation/widgets/resource_bar.dart`

Add a `consumption` parameter:
```dart
class ResourceBar extends StatelessWidget {
  final Map<ResourceType, Resource> resources;
  final Map<ResourceType, int> production;
  final Map<ResourceType, int> consumption;  // NEW — default empty
```

Pass `consumption[r.type] ?? 0` to each `ResourceBarItem`.

## Dependencies

- No domain dependencies (purely presentational)

## Test Plan

- File: `test/presentation/widgets/resource_bar_item_test.dart` (update or create)
- File: `test/presentation/widgets/resource_bar_test.dart` (update)
- See Task 12

## Notes

- Only energy and algae will have non-zero consumption in practice, but the widget is generic
- The spec says: `+10 / -8` format for energy, `+50 / -12` for algae
- Alert color from `AbyssColors.error` when consumption > production
