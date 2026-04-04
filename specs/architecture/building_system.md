# Building System — Architecture

## Overview

Buildings form the player's base. Each building has a type, a level (0 = not built), and can be upgraded by spending resources. The system is designed for easy extension with new building types.

## Domain Model

```
BuildingType (enum, Hive typeId: 4)
  headquarters | algaeFarm | coralMine | oreExtractor | solarPanel

Building (HiveObject, typeId: 5)
  ├── type: BuildingType
  └── level: int            (mutable, 0 = not built)

BuildingCostCalculator (stateless)
  ├── upgradeCost(type, level) → Map<ResourceType, int>
  ├── maxLevel(type) → int
  ├── prerequisites(type, targetLevel) → Map<BuildingType, int>
  └── checkUpgrade(...) → UpgradeCheck

UpgradeCheck (immutable result)
  ├── canUpgrade: bool
  ├── isMaxLevel: bool
  ├── missingResources: Map<ResourceType, int>
  └── missingPrerequisites: Map<BuildingType, int>

Game.buildings: Map<BuildingType, Building>
  └── Defaults via Game.defaultBuildings()
  └── Keyed by BuildingType (one building per type, like resources)
```

## Buildings

### Headquarters (QG)

| Property | Value |
|----------|-------|
| Max level | 10 |
| Cost formula | `base * (N² + 1)` |
| Costs | Coral: 30, Ore: 20 |
| Prerequisites | None |
| Production | None — gates other buildings |

### Production Buildings

All production buildings share: max level 5, cost formula `base * (N² + 1)`, prerequisite `HQ ≥ 2*(targetLevel - 1)` (min 1). Production per turn is computed by `ProductionFormula` (see [resource_system.md](resource_system.md)).

| Building | Costs | Produces |
|----------|-------|----------|
| Algae Farm | Coral: 20 | Algae |
| Coral Mine | Ore: 15 | Coral |
| Ore Extractor | Coral: 25, Energy: 15 | Ore |
| Solar Panel | Coral: 20, Ore: 15 | Energy |

## Upgrade Flow

1. Player taps building card → `BuildingDetailSheet` opens
2. `BuildingCostCalculator.checkUpgrade()` validates resources and prerequisites (display)
3. If valid, button is enabled; if not, missing items shown in red
4. On upgrade: `UpgradeBuildingAction` + `ActionExecutor` handle validation and mutation
5. `setState` refreshes both `ResourceBar` and `BuildingListView`

See [action_system.md](action_system.md) for the full action architecture.

## Presentation Layer

```
BuildingTypeExtensions
  ├── BuildingTypeColor  → color mapping
  └── BuildingTypeInfo   → displayName, description, iconPath

Widgets
  ├── BuildingIcon       → SVG with optional greyscale (level 0)
  ├── BuildingCard       → icon + name + level, dimmed when unbuilt
  ├── BuildingListView   → scrollable list of BuildingCard
  ├── BuildingDetailSheet → modal bottom sheet with full info
  └── UpgradeSection     → costs display + upgrade button
```

## Design Decisions

1. **Level 0 = not built** — Greyed out card (Opacity 0.5) + greyscale icon. No separate "locked" state.
2. **Instant upgrade** — No construction queue in phase 1. Will be added later.
3. **Stateless calculator** — `BuildingCostCalculator` has no dependencies, easy to test and swap formulas.
4. **UpgradeCheck as result object** — Encapsulates all failure reasons so the UI can display them.
5. **Switch expressions** — Cost/max-level/prerequisite logic uses exhaustive switch on `BuildingType`, forcing updates when new types are added.
6. **Map keyed by BuildingType** — Mirrors the `Map<ResourceType, Resource>` pattern. O(1) lookup, enforces one building per type at the type level.
7. **HQ as prerequisite gate** — Production buildings require HQ at `2*(targetLevel-1)` (min 1), creating a natural upgrade path.

## Hive Adapter Registration Order

BuildingType → Building → ResourceType → Resource → Player → Game

## File Structure

```
lib/domain/
  ├── building_type.dart
  ├── building.dart
  ├── building_cost_calculator.dart
  ├── production_formula.dart
  ├── production_formulas.dart
  └── upgrade_check.dart
lib/presentation/
  ├── extensions/building_type_extensions.dart
  └── widgets/
        ├── building_icon.dart
        ├── building_card.dart
        ├── building_list_view.dart
        ├── building_detail_sheet.dart
        └── upgrade_section.dart
```
