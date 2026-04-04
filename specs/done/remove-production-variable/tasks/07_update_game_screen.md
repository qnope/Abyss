# Task 07 — Update GameScreen to compute and pass production

## Summary

Use `ProductionCalculator.fromBuildings()` in `GameScreen` to compute production and pass it to `ResourceBar`.

## Implementation Steps

### Step 1: Edit `lib/presentation/screens/game_screen.dart`

Add import:

```dart
import '../../domain/production_calculator.dart';
```

In `build()`, compute production and pass to ResourceBar:

```dart
@override
Widget build(BuildContext context) {
  final production = ProductionCalculator.fromBuildings(widget.game.buildings);
  return Scaffold(
    body: Column(
      children: [
        ResourceBar(
          resources: widget.game.resources,
          production: production,
        ),
        Expanded(child: _buildTabContent()),
      ],
    ),
    ...
  );
}
```

## Dependencies

- Task 01 (ProductionCalculator exists)
- Task 06 (ResourceBar accepts `production`)

## Notes

- Production is recomputed on every `build()` call, which happens after `setState()` in `_upgradeBuilding()` and `_nextTurn()`. This ensures the display is always fresh.
