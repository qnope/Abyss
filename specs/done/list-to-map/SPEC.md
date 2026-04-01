# list-to-map Feature Specification

## 1. Feature Overview

Convert `List<Building>` to `Map<BuildingType, Building>` throughout the codebase to align with the existing resource pattern (`Map<ResourceType, Resource>`).

Each `BuildingType` maps to exactly one `Building` instance. This makes lookups by type O(1) instead of requiring `.where()` scans, and enforces the one-building-per-type invariant at the type level.

## 2. API Design

### Game domain model

The `Game` class field changes from:

```dart
final List<Building> buildings;
```

to:

```dart
final Map<BuildingType, Building> buildings;
```

The constructor parameter and `defaultBuildings()` factory follow the same change:

```dart
static Map<BuildingType, Building> defaultBuildings() {
  return {
    BuildingType.headquarters: Building(type: BuildingType.headquarters, level: 0),
  };
}
```

### BuildingCostCalculator

The `checkUpgrade` method parameter changes from `List<Building> allBuildings` to `Map<BuildingType, Building> allBuildings`. Building lookups like:

```dart
allBuildings.where((b) => b.type == entry.key).firstOrNull
```

become:

```dart
allBuildings[entry.key]
```

### Presentation widgets

All widgets receiving buildings switch to `Map<BuildingType, Building>`:

- **BuildingListView**: `List<Building> buildings` becomes `Map<BuildingType, Building> buildings`. Iterates over `.values`.
- **UpgradeSection**: `List<Building> allBuildings` becomes `Map<BuildingType, Building> allBuildings`. Prerequisite lookup uses direct map access.
- **BuildingDetailSheet** (and `showBuildingDetailSheet` function): `List<Building> allBuildings` becomes `Map<BuildingType, Building> allBuildings`.
- **GameScreen**: passes `widget.game.buildings` as-is (no conversion needed since Game now holds a Map).

## 3. Testing and Validation

### Unit tests

- Update `game_test.dart` assertions from `game.buildings.length` / `game.buildings.first` to map-based access (`game.buildings.length`, `game.buildings[BuildingType.headquarters]`).
- Update `building_cost_calculator_test.dart` to pass `Map<BuildingType, Building>` instead of `List<Building>` to `checkUpgrade`.

### Widget tests

- Update all widget tests that construct `List<Building>` fixtures to use `Map<BuildingType, Building>` instead.

### Validation

- `flutter analyze` must pass with zero issues.
- `flutter test` must pass with all tests green.
