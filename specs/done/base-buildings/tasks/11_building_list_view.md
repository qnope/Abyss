# Task 11 — BuildingListView Widget

## Summary

Create the `BuildingListView` widget that displays all buildings as a scrollable list of `BuildingCard` items. This replaces the `TabPlaceholder` for the Base tab.

## Implementation Steps

1. Create `lib/presentation/widgets/building_list_view.dart`
2. Define the widget:

```dart
class BuildingListView extends StatelessWidget {
  final List<Building> buildings;
  final Map<ResourceType, Resource> resources;
  final void Function(Building building) onBuildingTap;

  const BuildingListView({
    super.key,
    required this.buildings,
    required this.resources,
    required this.onBuildingTap,
  });
}
```

3. Build method:
   - Use `ListView.builder` with `itemCount: buildings.length`
   - Each item is a `Padding` wrapping a `BuildingCard`
   - Padding: `EdgeInsets.symmetric(horizontal: 16, vertical: 4)`
   - Top padding on first item: 16
   - `onTap` for each card calls `onBuildingTap(building)`

## Files

| Action | Path |
|--------|------|
| Create | `lib/presentation/widgets/building_list_view.dart` |

## Dependencies

- Task 02 (Building model)
- Task 10 (BuildingCard widget)

## Test Plan

- Tested in task 15 (`building_list_view_test.dart`)

## Notes

- `resources` is passed through for future use (e.g., showing resource indicators on cards) but not used in this first version
- The `onBuildingTap` callback will open the detail sheet (wired in task 14)
- The list is scrollable per US-01: "La liste est scrollable si le nombre de bâtiments dépasse l'écran"
